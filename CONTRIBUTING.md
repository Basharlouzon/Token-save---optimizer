# Contributing to Tokenso

Thank you for your interest in contributing to Tokenso! This guide covers everything you need to get started.

## Quick Start

```bash
git clone https://github.com/Basharlouzon/Token-save---optimizer.git
cd Token-save---optimizer
make install-local
```

## Development

### Prerequisites

- Bash 3.2+ (macOS default) or Bash 4+ (Linux)
- [shellcheck](https://github.com/koalaman/shellcheck) for linting
- Optional: `jq`, `ripgrep`, `tree`, `bc` for full feature testing

### Project Structure

```
bin/tokenso                    Main CLI (single-file Bash script)
install.sh                     Global installer (curl | bash)
scripts/init-smart-search.sh   Repo map generator
scripts/apply-cross-rules.sh   Cross-agent rules injector
.claude/skills/brainstorming/SKILL.md  Brainstorming skill for Claude Code
SKILL.md                       Tokenso optimizer skill definition
README.md                      User-facing documentation
```

### Linting

```bash
make lint
```

This runs `shellcheck` on all Bash files. All contributions must pass linting with zero warnings.

### Local Testing

```bash
make install-local             # Symlinks bin/tokenso to /usr/local/bin
tokenso install                # Run the wizard in a test project
tokenso run                    # Test the mindmap
tokenso stats --html           # Test HTML dashboard generation
```

### Uninstalling Local Build

```bash
make uninstall-local
```

## Making Changes

### Code Style

- Pure Bash — no external language dependencies
- Use `set -o pipefail` at the top of scripts
- Prefer POSIX constructs where possible; use Bash-specific features when they improve readability
- All user-facing output goes to stderr (`>&2`) for install/setup scripts; stdout is reserved for data output (JSON, CSV)
- Use the existing color variable pattern: `GREEN`, `BBLUE`, `NC`, etc.
- Keep functions small and single-purpose
- Add `shellcheck` directives only when a false positive cannot be avoided

### Commit Messages

Follow conventional commit style:

```
feat: add new AI tool support
fix: handle missing tree command gracefully
docs: update README with new flag
refactor: extract stats loading into helper
```

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/my-feature`)
3. Make your changes
4. Run `make lint` and ensure it passes
5. Test manually in a sample project
6. Open a PR with a clear description of the change and motivation

### Adding a New AI Tool

To add support for a new AI coding tool:

1. Add the tool to the `detect_tools()` function in `bin/tokenso`
2. Add a new case in the `run_install()` wizard menu
3. Add the tool to `scripts/apply-cross-rules.sh`
4. Update the README compatibility table
5. Add a completion entry in `install.sh` (both zsh and bash)

## Reporting Issues

When reporting bugs, please include:

- Your OS and shell version (`bash --version`)
- Tokenso version (`tokenso --version`)
- Steps to reproduce
- Expected vs actual output

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
