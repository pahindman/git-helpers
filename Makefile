# Default install directory
PREFIX ?= $(HOME)/.local
BIN_DIR := $(PREFIX)/bin
MAN_DIR := $(PREFIX)/share/man/man1
REPO_DIR := $(shell pwd)

# Find all git-* files at the base of the repo
SCRIPTS := $(wildcard git-*)
MANPAGES := $(wildcard man/git-*.1)

.PHONY: install uninstall

install:
	@mkdir -p $(BIN_DIR) $(MAN_DIR)
	@for script in $(SCRIPTS); do \
		ln -sf "$(REPO_DIR)/$$script" "$(BIN_DIR)/$$script"; \
		echo "Linked $$script -> $(BIN_DIR)/$$script"; \
	done
	@for manpage in $(MANPAGES); do \
		filename=$$(basename "$$manpage"); \
		ln -sf "$(REPO_DIR)/$$manpage" "$(MAN_DIR)/$$filename"; \
		echo "Linked $$filename -> $(MAN_DIR)/$$filename"; \
	done

uninstall:
	@for script in $(SCRIPTS); do \
		target="$(BIN_DIR)/$$script"; \
		if [ -L "$$target" ]; then \
			link_dest=$$(readlink "$$target"); \
			case "$$link_dest" in \
				"$(REPO_DIR)"/*) \
					rm -f "$$target"; \
					echo "Removed $$target (pointed to $(REPO_DIR))"; \
					;; \
				*) \
					echo "Skipped $$target (symlink points elsewhere: $$link_dest)"; \
					;; \
			esac; \
		elif [ -e "$$target" ]; then \
			echo "Skipped $$target (not a symlink)"; \
		fi; \
	done
	@for manpage in $(MANPAGES); do \
		filename=$$(basename "$$manpage"); \
		target="$(MAN_DIR)/$$filename"; \
		if [ -L "$$target" ]; then \
			link_dest=$$(readlink "$$target"); \
			case "$$link_dest" in \
				"$(REPO_DIR)"/*) \
					rm -f "$$target"; \
					echo "Removed $$target"; \
					;; \
				*) \
					echo "Skipped $$target (symlink points elsewhere: $$link_dest)"; \
					;; \
			esac; \
		elif [ -e "$$target" ]; then \
			echo "Skipped $$target (not a symlink)"; \
		fi; \
	done
