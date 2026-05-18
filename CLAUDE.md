
# ==========================================
# TOKENSO CONTEXT OPTIMIZER RULES
# ==========================================
- **Search Diet**: Do not read full files blindly. Check file size first. Use lightweight search to find filenames before reading. Only read specific line ranges required.
- **Smart Init**: If you need to explore the project, do not run `ls -R`. Instead, run `bash .ai-memory/scripts/init-smart-search.sh .` and read `.ai-memory/repo-map.txt`.
- **Memory Protocol**: Before acting, always read `.ai-memory/state.md`. Upon reaching a milestone or repeating actions, compress your current understanding into `.ai-memory/state.md` and explicitly command yourself to forget the prior raw context to save tokens.
- **Stop Duplication**: If you find yourself in a loop or re-reading the same files, STOP. Update the memory state and ask the user for clarification.

# ==========================================
# RELEASE & PUSH RULES (user-set, persistent)
# ==========================================
- **Default branch**: `master` on `origin` (https://github.com/Basharlouzon/Token-save---optimizer).
- **Release Trigger**: Whenever the user asks to *update*, *fix*, *enhance*, or *improve* the project, after the change is complete you MUST:
  1. Bump `VERSION` in `bin/tokenso:14` (patch for fixes, minor for enhancements/new features, major for breaking changes) — follow the `release-manager` skill.
  2. Update the version badge on `README.md:3` and add a short "What's new" entry.
  3. Commit with a Conventional Commits message (`feat:` / `fix:` / `refactor:` / `docs:` …).
  4. `git push origin master` — and tag + `gh release create` if it's a user-visible release.
- **Confirmation**: Before pushing destructive or non-fix commits to master, summarize the diff in one line and proceed. If the change is risky (schema break, marker bump, install-script edit), pause for explicit user OK.
- **Architecture Changes**: Non-trivial design decisions go through the `/architecture` skill and produce an ADR in `docs/adr/` before merging.
