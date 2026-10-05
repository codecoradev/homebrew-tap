<!--
PR title must follow Conventional Commits — it becomes the squash commit message.
Format: type(scope): short description
Examples: fix(formula): correct sha256 / chore(ci): bump checkout version
-->

## What
<!-- One or two sentences describing the change. -->

## Why
<!-- The problem you're solving. Link to the issue if there is one. -->

## How
<!-- Brief notes on the approach, only if non-obvious. -->

## Testing

- [ ] `brew style codecoradev/tap/uteke` passes
- [ ] `brew audit --strict --formula codecoradev/tap/uteke` passes
- [ ] `brew install codecoradev/tap/uteke && brew test codecoradev/tap/uteke` passes locally
- [ ] Note: `Formula/uteke.rb` is generated — edit `scripts/update_formula.py` instead

## Related Issues
<!-- Link to related issues -->

## Checklist

- [ ] Branch name follows convention (`fix/`, `feat/`, `docs/`, `chore/`, `ci/`)
- [ ] Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
- [ ] No secrets or credentials committed
- [ ] One logical change per PR (no mixed concerns)
