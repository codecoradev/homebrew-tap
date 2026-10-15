class Uteke < Formula
  desc "Persistent memory engine for AI agents (offline, MCP-ready)"
  homepage "https://uteke.app"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/codecoradev/uteke/releases/download/v0.21.1/uteke-aarch64-apple-darwin-v0.21.1.tar.gz"
      sha256 "d4927e8f93e4460d0503a4055bd884c3b734f2fd520b559c2c8331576e7d253a"
    else
      # No macOS Intel prebuilt exists (ort-sys provides none).
      raise "uteke v0.21.1: no macOS Intel prebuilt; build from source (cargo install uteke-cli)"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/codecoradev/uteke/releases/download/v0.21.1/uteke-aarch64-unknown-linux-gnu-v0.21.1.tar.gz"
      sha256 "e043d915664f1f64e0d22bb5dcba71dc8bf0d1111ccbe2f8c3624a0fce684c67"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/codecoradev/uteke/releases/download/v0.21.1/uteke-x86_64-unknown-linux-gnu-v0.21.1.tar.gz"
      sha256 "341726772572d2b0c2f645236b5509e8f162a53dfa98c77c6a194336ae84626b"
    else
      raise "uteke v0.21.1: unsupported architecture"
    end
  end

  def install
    # Release tarballs ship libonnxruntime next to the binaries; uteke loads it
    # from its own directory or $ORT_LIB_PATH (see INSTALL.md). Keep them
    # together in libexec and export ORT_LIB_PATH via the bin shims.
    # ORT_LIB_PATH must name the library FILE: uteke dlopens exactly that path,
    # so pointing it at the directory leaves every install without embeddings.
    %w[uteke uteke-serve uteke-mcp].each { |b| libexec.install b }
    libexec.install Dir["libonnxruntime*"]
    ort_lib = libexec/(OS.mac? ? "libonnxruntime.dylib" : "libonnxruntime.so")
    %w[uteke uteke-serve uteke-mcp].each do |b|
      (bin/b).write_env_script(libexec/b, ORT_LIB_PATH: ort_lib)
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

    # The shims must point ORT_LIB_PATH at an existing library file, not a
    # directory; otherwise uteke silently stores memories without embeddings.
    %w[uteke uteke-serve uteke-mcp].each do |b|
      ort_lib = (bin/b).read[/ORT_LIB_PATH="([^"]+)"/, 1]
      refute_nil ort_lib, "#{b} shim does not set ORT_LIB_PATH"
      assert_predicate Pathname(ort_lib), :file?, "#{b}: ORT_LIB_PATH is not a file: #{ort_lib}"
    end
  end
end
