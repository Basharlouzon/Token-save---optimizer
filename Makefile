SHELLCHECK := $(shell command -v shellcheck 2>/dev/null)
BASH_FILES := $(shell find . -name '*.sh' -not -path './.git/*' -not -path './.ai-memory/*') bin/tokenso

.PHONY: lint install-local uninstall-local check help

help:
	@echo "Tokenso Development Commands:"
	@echo "  lint             Run shellcheck on all Bash files"
	@echo "  install-local    Symlink bin/tokenso to /usr/local/bin"
	@echo "  uninstall-local  Remove symlink from /usr/local/bin"
	@echo "  check            Run all checks (lint)"

lint:
ifndef SHELLCHECK
	$(error "shellcheck is not installed. Install it via: brew install shellcheck (macOS) or apt install shellcheck (Linux)")
endif
	shellcheck -x -s bash $(BASH_FILES)

install-local:
	ln -sf "$(PWD)/bin/tokenso" /usr/local/bin/tokenso
	@echo "✓ Symlinked $(PWD)/bin/tokenso → /usr/local/bin/tokenso"

uninstall-local:
	rm -f /usr/local/bin/tokenso
	@echo "✓ Removed /usr/local/bin/tokenso symlink"

check: lint
	@echo "✓ All checks passed"
