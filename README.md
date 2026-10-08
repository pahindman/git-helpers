# git-helpers

[![CI](https://github.com/pahindman/git-helpers/actions/workflows/ci.yml/badge.svg?branch=main&event=push)](https://github.com/pahindman/git-helpers/actions/workflows/ci.yml)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/pahindman/git-helpers/main.svg)](https://results.pre-commit.ci/latest/github/pahindman/git-helpers/main)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A small collection of git subcommands that automate common repository maintenance tasks.

## Installation

Install the helpers as symlinks in your local bin directory:

```bash
make install
```

By default this symlinks every script in the repository root into `~/.local/bin` and links the man page into `~/.local/share/man/man1`.

To override the install prefix:

```bash
PREFIX=/usr/local make install
```

To remove the symlinks created by the project:

```bash
make uninstall
```

## Commands

Once installed, each script is available as a git subcommand by its filename.

- `git cleanup-branches [-n|--dry-run] [base-branch]`
  - Deletes local branches already merged into a chosen base branch.
  - If no base branch is provided, the script lists branches and prompts for one.
  - `--dry-run` shows which branches would be deleted without changing the repo.

- `git diff-commits <commit1> <commit2>`
  - Compares two commits side by side using `git difftool --no-index`.

- `git diff-staged-vs [refname]`
  - Compares the current staged diff against a commit or ref (defaults to `REBASE_HEAD`).

- `git find-time-travellers [-d DAYS] [rev]`
  - Lists commits where the commit date is more than `DAYS` after the author date, or where the commit date is earlier than the author date.
  - Defaults to `14` days and `HEAD`.

- `git pull-branches [-n|--dry-run]`
  - Checks out each local branch and runs `git pull`, repeating until no branch changes.
  - Refuses to run when working tree or index changes are present.
  - `--dry-run` reports which branches would be pulled without modifying any branch state.

- `git status-push`
  - Prints each local branch's status relative to its push remote, including ahead/behind counts.

- `git update-remote-branches [-n|--dry-run]`
  - Pushes tracked branches to their configured remote using `--force-with-lease` when they are out of sync.
  - `--dry-run` reports which branches would be pushed without updating the remote.

## Example

```bash
git find-time-travellers -d 30 HEAD
git cleanup-branches main
```
