# Default install directory
PREFIX ?= $(HOME)/.local
BIN_DIR := $(PREFIX)/bin
MAN_DIR := $(PREFIX)/share/man/man1
REPO_DIR := $(shell pwd)

# Use symlinks unless the user specifies otherwise
USE_SYMLINKS ?= 1

# Find all git-* files at the base of the repo
SCRIPTS := $(wildcard git-*)
INSTALLED_SCRIPTS := $(addprefix $(BIN_DIR)/, $(SCRIPTS))

# Find all man pages in the man directory
MANPAGES := $(wildcard man/git-*.1)
INSTALLED_MANPAGES := $(addprefix $(MAN_DIR)/, $(notdir $(MANPAGES)))

.PHONY: all

all:
	@echo "Run 'make install' to install scripts and dependencies."

#### INSTALL TARGETS ####

ifeq ($(USE_SYMLINKS),1)
    INSTALL_CMD = ln -s $(realpath $<) $@ && echo "Linked $@ -> $(realpath $<)" || echo "Skipped linking $@ to $(realpath $<)"
else
    INSTALL_CMD = cp -n $< $@ && echo "Copied $(realpath $<) to $@" || echo "Error copying $(realpath $<)  to $@"
endif

.PHONY: install install-scripts install-manpages

install: install-helpers install-scripts install-manpages

install-scripts: $(INSTALLED_SCRIPTS)
	@echo "Script installation complete. Ensure $(BIN_DIR) is in your PATH."

$(BIN_DIR)/git-%: git-% | $(BIN_DIR)
	@$(INSTALL_CMD)

$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

install-manpages: $(INSTALLED_MANPAGES)

$(MAN_DIR)/git-%.1: man/git-%.1 | $(MAN_DIR)
	@$(INSTALL_CMD)

$(MAN_DIR):
	@mkdir -p $(MAN_DIR)

#### UNINSTALL TARGETS ####
.PHONY: uninstall uninstall-scripts uninstall-manpages

uninstall: uninstall-manpages uninstall-scripts uninstall-helpers

# Uninstall scripts only if they are symlinks pointing to the repo
uninstall-scripts:
	@for script in $(SCRIPTS); do \
		installed_script="$(BIN_DIR)/$$script"; \
		if [ "$(USE_SYMLINKS)" -eq 1 ]; then \
			if [ -L "$$installed_script" ]; then \
				link_target=$$(readlink "$$installed_script"); \
				if [ "$$link_target" = "$(REPO_DIR)/$$script" ]; then \
					rm -f "$$installed_script"; \
					echo "Removed $$installed_script"; \
				else \
					echo "Skipped $$installed_script (symlink points elsewhere: $$link_target)"; \
				fi; \
			elif [ -e "$$installed_script" ]; then \
				echo "Skipped $$installed_script (not a symlink)"; \
			fi; \
		else \
			if [ -L "$$installed_script" ]; then \
				echo "Skipped $$installed_script (is a symlink, expected regular file)"; \
			elif [ -e "$$installed_script" ]; then \
				rm -f "$$installed_script"; \
				echo "Removed $$installed_script"; \
			fi; \
		fi; \
	done

# Uninstall man pages only if they are symlinks pointing to the repo
uninstall-manpages:
	@for manpage in $(MANPAGES); do \
		filename=$$(basename "$$manpage"); \
		installed_manpage="$(MAN_DIR)/$$filename"; \
		if [ "$(USE_SYMLINKS)" -eq 1 ]; then \
			if [ -L "$$installed_manpage" ]; then \
				link_target=$$(readlink "$$installed_manpage"); \
				if [ "$$link_target" = "$(REPO_DIR)/$$manpage" ]; then \
					rm -f "$$installed_manpage"; \
					echo "Removed $$installed_manpage"; \
				else \
					echo "Skipped $$installed_manpage (symlink points elsewhere: $$link_target)"; \
				fi; \
			elif [ -e "$$installed_manpage" ]; then \
				echo "Skipped $$installed_manpage (not a symlink)"; \
			fi; \
		else \
			if [ -L "$$installed_manpage" ]; then \
				echo "Skipped $$installed_manpage (is a symlink, expected regular file)"; \
			elif [ -e "$$installed_manpage" ]; then \
				rm -f "$$installed_manpage"; \
				echo "Removed $$installed_manpage"; \
			fi; \
		fi; \
	done

HELPER_DIR ?= lib/bash-helpers

# Ensure helper Makefile exists before delegating
$(HELPER_DIR)/Makefile:
	@if [ ! -f "$@" ]; then \
		echo "Initializing bash-helpers submodule..."; \
		git submodule update --init --recursive; \
	fi

.PHONY: install-helpers
install-helpers: $(HELPER_DIR)/Makefile
	$(MAKE) -C $(HELPER_DIR) install PREFIX=$(PREFIX) USE_SYMLINKS=$(USE_SYMLINKS)

.PHONY: uninstall-helpers
uninstall-helpers: $(HELPER_DIR)/Makefile
	$(MAKE) -C $(HELPER_DIR) uninstall PREFIX=$(PREFIX) USE_SYMLINKS=$(USE_SYMLINKS)
