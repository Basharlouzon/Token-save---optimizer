# Changelog

All notable changes to Tokenso are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.2.0] — 2026-05-17

### Added
- Brainstorming skill for Claude Code (`.claude/skills/brainstorming/SKILL.md`) — enforces design-first workflow with spec approval gates
- Claude Code config files (`.claudecode` + `CLAUDE.md`) auto-generated on install
- Install wizard now deploys brainstorming skill when Claude Code (option 1) is selected
- CONTRIBUTING.md with development guidelines
- Makefile with `lint`, `install-local`, `uninstall-local`, and `check` targets
- CHANGELOG.md for version tracking
- Expanded .gitignore for IDE artifacts and `.claude/` directory
- Schema version field (`"schema": 1`) in optimizer-stats.json for future migrations
- Shellcheck directives for known safe patterns

### Fixed
- Fixed typo in `.ai-memory/state.md` header (`x#` → `#`)
- Installer no longer hangs under `curl | bash` — auto-detects missing TTY and switches to unattended mode
- Timeout-bounded download in installer (10s connect, 120s total)
- Explicit sudo password prompt before elevation

## [2.1.0] — 2026-05-17

### Added
- Cumulative stats tracking with sparkline trend across sessions
- Model cost comparison matrix (Sonnet 4, Opus 4, Gemini 2.5 Pro, GPT-4.1)
- Premium HTML visual dashboard with interactive savings calculator and milestone timeline
- JSON and CSV export formats (`tokenso stats --json`, `tokenso stats --csv`)
- `tokenso reset` command to clear cumulative stats while preserving install date
- `tokenso update` command to self-update from GitHub

### Fixed
- Idempotent installer — re-running does not duplicate PATH or completion blocks
- Graceful fallback when optional tools (`jq`, `bc`, `rg`, `tree`) are missing

## [2.0.0] — 2026-05-16

### Added
- Renamed CLI from `tokensaveoptimizer` to `tokenso`
- Interactive ASCII dashboard as default command
- Cognitive mindmap GUI with animated node connections (`tokenso run`)
- Multi-tool install wizard supporting 16+ AI tools
- Antigravity (Google DeepMind) global skill installation
- Agent auto-detection showing active tools in dashboard
- `tokenso save` command with optional milestone notes
- Zero-waste code search (`tokenso search`)

## [1.0.0] — 2026-05-15

### Added
- Initial release
- Smart search memory initialization
- Compressed repository map generation
- Cross-agent rule injection for Claude Code, Cline, Cursor, and 12 other tools
- Persistent AI memory state protocol
