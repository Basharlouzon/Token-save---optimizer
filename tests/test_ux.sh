#!/bin/bash
# tests/test_ux.sh — smoke tests for two-tier command groups
# Run from repo root: bash tests/test_ux.sh

set -uo pipefail
PASS=0; FAIL=0
BIN="$(cd "$(dirname "$0")/.." && pwd)/bin/tokenso"
TMPDIR_TEST=$(mktemp -d)
trap 'rm -rf "$TMPDIR_TEST"' EXIT

assert_contains() {
    local desc="$1" output="$2" pattern="$3"
    if echo "$output" | grep -q "$pattern"; then
        echo "  PASS  $desc"
        PASS=$((PASS+1))
    else
        echo "  FAIL  $desc"
        echo "        expected pattern: $pattern"
        echo "        actual output snippet: $(echo "$output" | head -5)"
        FAIL=$((FAIL+1))
    fi
}

assert_not_contains() {
    local desc="$1" output="$2" pattern="$3"
    if ! echo "$output" | grep -q "$pattern"; then
        echo "  PASS  $desc"
        PASS=$((PASS+1))
    else
        echo "  FAIL  $desc"
        echo "        pattern should be absent: $pattern"
        FAIL=$((FAIL+1))
    fi
}

cd "$TMPDIR_TEST"

echo ""
echo "── tokenso UX tests ────────────────────────────────────"

# Test 1: help shows daily tier label
OUT=$("$BIN" help 2>&1 || true)
assert_contains    "help: shows DAILY COMMANDS heading"   "$OUT" "DAILY COMMANDS"

# Test 2: help does NOT dump the full management list inline
assert_not_contains "help: no 'config install' in main body" "$OUT" "config install"

# Test 3: help all shows old full dashboard (ASCII art banner)
OUT_ALL=$("$BIN" help all 2>&1 || true)
assert_contains    "help all: contains ASCII banner"      "$OUT_ALL" "TOKENSO\|tokenso\|Save Optimizer"

# Test 4: tokenso config (no subcommand) shows config help
OUT_CFG=$("$BIN" config 2>&1 || true)
assert_contains    "config: shows config subcommands"     "$OUT_CFG" "config install"

# Test 5: bare tokenso (no .ai-memory) shows compact not-initialized message
OUT_BARE=$("$BIN" 2>&1 || true)
assert_not_contains "bare tokenso: no ASCII art banner"   "$OUT_BARE" "╗"

echo ""
echo "── Results: $PASS passed, $FAIL failed ─────────────────"
[ $FAIL -eq 0 ] && exit 0 || exit 1
