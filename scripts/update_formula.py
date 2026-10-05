#!/usr/bin/env python3
"""Regenerate Formula/uteke.rb for a new uteke release.

Single source of truth for the formula: the release automation job in
codecoradev/uteke (release.yml -> update-tap) runs this against the freshly
published checksums-sha256.txt and opens a PR to this repo.

Usage:
  update_formula.py --version 0.19.0 --checksums checksums-sha256.txt [--out Formula/uteke.rb]
"""
import argparse
import pathlib
import sys

TEMPLATE = """class Uteke < Formula
  desc "Persistent memory engine for AI agents (offline, MCP-ready)"
  homepage "https://uteke.app"
  version "{version}"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/codecoradev/uteke/releases/download/v{version}/uteke-aarch64-apple-darwin-v{version}.tar.gz"
      sha256 "{mac_arm}"
    else
      raise "uteke v{version} ships no macOS Intel prebuilt (ort-sys provides none). Build from source: cargo install uteke-cli"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/codecoradev/uteke/releases/download/v{version}/uteke-aarch64-unknown-linux-gnu-v{version}.tar.gz"
      sha256 "{linux_arm}"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/codecoradev/uteke/releases/download/v{version}/uteke-x86_64-unknown-linux-gnu-v{version}.tar.gz"
      sha256 "{linux_x86}"
    else
      raise "uteke v{version}: unsupported architecture"
    end
  end

  def install
    # Release tarballs ship libonnxruntime next to the binaries; uteke loads it
    # from its own directory or $ORT_LIB_PATH (see INSTALL.md). Keep them
    # together in libexec and export ORT_LIB_PATH via the bin shims.
    %w[uteke uteke-serve uteke-mcp].each {{ |b| libexec.install b }}
    libexec.install Dir["libonnxruntime*"]
    %w[uteke uteke-serve uteke-mcp].each do |b|
      (bin/b).write_env_script(libexec/b, ORT_LIB_PATH: libexec)
    end
  end

  def caveats
    <<~EOS
      Managed by Homebrew: use `brew upgrade codecoradev/tap/uteke` instead of
      the built-in `uteke upgrade`.

      macOS: Apple Silicon only — there is no Intel prebuilt. Intel users can
      build from source with `cargo install uteke-cli`.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{{bin}}/uteke --version")
    assert_match "memory", shell_output("#{{bin}}/uteke --help")
  end
end
"""

def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--version", required=True, help="uteke version WITHOUT the v prefix, e.g. 0.19.0")
    ap.add_argument("--checksums", required=True, help="path to checksums-sha256.txt from the release")
    ap.add_argument("--out", default="Formula/uteke.rb")
    args = ap.parse_args()

    if args.version.startswith("v"):
        sys.exit("version must not start with 'v'")

    shas: dict[str, str] = {}
    for line in pathlib.Path(args.checksums).read_text().splitlines():
        parts = line.split()
        if len(parts) != 2:
            continue
        digest, name = parts
        if "aarch64-apple-darwin" in name:
            shas["mac_arm"] = digest
        elif "aarch64-unknown-linux" in name:
            shas["linux_arm"] = digest
        elif name.startswith("uteke-x86_64-unknown-linux-gnu-") and "legacy" not in name:
            shas["linux_x86"] = digest

    missing = [k for k in ("mac_arm", "linux_arm", "linux_x86") if k not in shas]
    if missing:
        sys.exit(f"checksums-sha256.txt missing targets: {missing}")

    out = pathlib.Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(TEMPLATE.format(version=args.version, **shas))
    print(f"wrote {args.out} for v{args.version}")

if __name__ == "__main__":
    main()
