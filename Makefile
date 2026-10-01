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

.PHONY: all \
	install install-scripts install-manpages \
	uninstall uninstall-scripts uninstall-manpages 

all:
	@echo "Run 'make install' to install scripts and dependencies."

#### INSTALL TARGETS ####

ifeq ($(USE_SYMLINKS),1)
    INSTALL_CMD = ln -sf $(realpath $<) $@ && echo "Created symlink: $@ -> $(realpath $<)"
else
    INSTALL_CMD = cp $< $@ && echo "Copied file: $< to $@"
endif

install: install-scripts install-manpages

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
uninstall: uninstall-scripts uninstall-manpages

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

# # Required dependency configuration
# LIB_NAME := library-foo.bash
# LIB_REPO := https://github.com/your-org/bash-libraries.git

# # Check if the library is in PATH (or specified location)
# check-deps:
# 	@if command -v $(LIB_NAME) >/dev/null 2>&1; then \
# 		echo "Found dependency: $$(command -v $(LIB_NAME))"; \
# 	else \
# 		echo "Dependency '$(LIB_NAME)' not found in PATH."; \
# 		$(MAKE) fetch-deps; \
# 	fi

# # Automatically clone and install the library if missing
# fetch-deps:
# 	@echo "Installing missing dependency '$(LIB_NAME)' to $(PREFIX)..."
# 	@TMPDIR=$$(mktemp -d) && \
# 		git clone --depth 1 $(LIB_REPO) "$$TMPDIR" && \
# 		$(MAKE) -C "$$TMPDIR" install PREFIX=$(PREFIX) && \
# 		rm -rf "$$TMPDIR"

# install: check-deps
# 	@echo "Installing scripts to $(BIN_DIR)..."
# 	install -d $(BIN_DIR)
# 	install -m 0755 src/* $(BIN_DIR)/
# 	@echo "Installation complete."
