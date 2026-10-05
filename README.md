# codecoradev/homebrew-tap

Official Homebrew tap for [Uteke](https://github.com/codecoradev/uteke) — persistent memory for AI agents.

## Install

```bash
brew tap codecoradev/tap
brew install uteke
```

or in one line:

```bash
brew install codecoradev/tap/uteke
```

## Coverage

| Platform | Status |
|---|---|
| macOS Apple Silicon (M1–M4) | ✅ prebuilt |
| Linux x86_64 | ✅ prebuilt |
| Linux aarch64 | ✅ prebuilt |
| macOS Intel | ❌ no prebuilt exists — build from source: `cargo install uteke-cli` |

The formula ships the ONNX Runtime libraries next to the binaries in
`libexec` and exports `ORT_LIB_PATH` through the `bin/` shims, so semantic
embeddings work out of the box with no extra setup. Verify with `uteke doctor`.

## Upgrades

While installed via this tap, use:

```bash
brew upgrade codecoradev/tap/uteke
```

instead of the built-in `uteke upgrade`.

## Automation

`Formula/uteke.rb` is **generated** — do not edit by hand.
`scripts/update_formula.py` regenerates it from a release `checksums-sha256.txt`.
On every uteke release, `codecoradev/uteke`'s release workflow opens a PR here
automatically; CI (`brew audit` + `brew test` on macOS and Linux) validates it
before merge.
