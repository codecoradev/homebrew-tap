class Uteke < Formula
  desc "Persistent memory engine for AI agents (offline, MCP-ready)"
  homepage "https://uteke.app"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/codecoradev/uteke/releases/download/v0.19.1/uteke-aarch64-apple-darwin-v0.19.1.tar.gz"
      sha256 "d2a754a13b1c72c395bfaa67fa9838ea014acec8516e8160534c908dbcd7bdc0"
    else
      # No macOS Intel prebuilt exists (ort-sys provides none).
      raise "uteke v0.19.1: no macOS Intel prebuilt; build from source (cargo install uteke-cli)"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/codecoradev/uteke/releases/download/v0.19.1/uteke-aarch64-unknown-linux-gnu-v0.19.1.tar.gz"
      sha256 "72d67e6dd1dc626caf9d855abf698926785a329693221776dc15222f22d22a4c"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/codecoradev/uteke/releases/download/v0.19.1/uteke-x86_64-unknown-linux-gnu-v0.19.1.tar.gz"
      sha256 "0f40c3e4a140314aaeb3704d4c84a06ac05561835579716e790c0d9360aeb40f"
    else
      raise "uteke v0.19.1: unsupported architecture"
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
