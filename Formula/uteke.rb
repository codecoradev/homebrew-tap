class Uteke < Formula
  desc "Persistent memory engine for AI agents (offline, MCP-ready)"
  homepage "https://uteke.app"
  version "0.19.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/codecoradev/uteke/releases/download/v0.19.0/uteke-aarch64-apple-darwin-v0.19.0.tar.gz"
      sha256 "c9b1512a5d8518660ea68b1d5b78da7dd0734d78419a59318dc075d6d7270149"
    else
      # No macOS Intel prebuilt exists (ort-sys provides none).
      raise "uteke v0.19.0: no macOS Intel prebuilt; build from source (cargo install uteke-cli)"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/codecoradev/uteke/releases/download/v0.19.0/uteke-aarch64-unknown-linux-gnu-v0.19.0.tar.gz"
      sha256 "8975ba3d279a5bcc7f4f48284f807c8999fc5b65b294fd1410435f903330d1cf"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/codecoradev/uteke/releases/download/v0.19.0/uteke-x86_64-unknown-linux-gnu-v0.19.0.tar.gz"
      sha256 "fb3c2cc1a69293c1897e67c345eb8d64cebcacc28561cc197bd227d83a010b44"
    else
      raise "uteke v0.19.0: unsupported architecture"
    end
  end

  def install
    # Release tarballs ship libonnxruntime next to the binaries; uteke loads it
    # from its own directory or $ORT_LIB_PATH (see INSTALL.md). Keep them
    # together in libexec and export ORT_LIB_PATH via the bin shims.
    %w[uteke uteke-serve uteke-mcp].each { |b| libexec.install b }
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
    assert_match version.to_s, shell_output("#{bin}/uteke --version")
    assert_match "memory", shell_output("#{bin}/uteke --help")
  end
end
