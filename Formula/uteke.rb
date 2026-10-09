class Uteke < Formula
  desc "Persistent memory engine for AI agents (offline, MCP-ready)"
  homepage "https://uteke.app"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/codecoradev/uteke/releases/download/v0.20.1/uteke-aarch64-apple-darwin-v0.20.1.tar.gz"
      sha256 "fb004871a87dd62816e8edbedbb0ff2b3b4e364e2eb27e0a4c23eab6bc69923b"
    else
      # No macOS Intel prebuilt exists (ort-sys provides none).
      raise "uteke v0.20.1: no macOS Intel prebuilt; build from source (cargo install uteke-cli)"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/codecoradev/uteke/releases/download/v0.20.1/uteke-aarch64-unknown-linux-gnu-v0.20.1.tar.gz"
      sha256 "eb6b3dabf8dfda7344e059dc927090a8b580584aa312924d866b995a1abc1ca5"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/codecoradev/uteke/releases/download/v0.20.1/uteke-x86_64-unknown-linux-gnu-v0.20.1.tar.gz"
      sha256 "cbf7a39316592066349fde16a1cd0c24cb83fd874f3ae5bc6fa8299603f37c79"
    else
      raise "uteke v0.20.1: unsupported architecture"
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
