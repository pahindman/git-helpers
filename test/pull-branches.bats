#!/usr/bin/env bash

setup() {
	load 'test_helper/bats-support/load'
	load 'test_helper/bats-assert/load'

	TEST_REPO="$BATS_TEST_TMPDIR/test-repo"
	mkdir -p "$TEST_REPO"
	cd "$TEST_REPO" || return 1

	git init -q
	git config user.name "Test User"
	git config user.email "test@example.com"
	export PATH="$BATS_TEST_DIRNAME/..:$PATH"
	export BASH_LIB_DIR="$BATS_TEST_DIRNAME/../lib/bash-libs"
}

teardown() {
	cd "$BATS_TEST_DIRNAME" || return 1
}

# bats file_tags=pull-branches

@test "git pull-branches succeeds on a clean repository" {
	git init -q --bare "$BATS_TEST_TMPDIR/remote.git"
	git remote add origin "$BATS_TEST_TMPDIR/remote.git"
	git checkout -b main

	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q
	git push -u origin main -q

	run git pull-branches
	assert_success
}

@test "git pull-branches fails fast when not in a git repository" {
	cd "$BATS_TEST_TMPDIR" || return 1

	run git pull-branches
	assert_failure
	assert_output --partial "Not a git repository"
}

@test "git pull-branches fails fast when the worktree has unstaged changes" {
	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q

	echo dirty >>tracked.txt

	run git pull-branches
	assert_failure
	assert_output --partial "unstaged changes"
}

@test "git pull-branches fails fast when the index has uncommitted changes" {
	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q

	echo dirty >>tracked.txt
	git add tracked.txt

	run git pull-branches
	assert_failure
	assert_output --partial "uncommitted changes"
}

@test "git pull-branches --dry-run prints branches without changing state" {
	git init -q --bare "$BATS_TEST_TMPDIR/remote.git"
	git remote add origin "$BATS_TEST_TMPDIR/remote.git"
	git checkout -b main

	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q
	git push -u origin main -q

	git checkout -b feature
	echo feature >>tracked.txt
	git add tracked.txt
	git commit -m "feature commit" -q

	run git pull-branches --dry-run
	assert_success
	assert_output --partial "Would try to pull branch 'main'"
	assert_output --partial "Would try to pull branch 'feature'"

	run git rev-parse --abbrev-ref HEAD
	assert_success
	assert_output "feature"
}

@test "git pull-branches fails fast when bisect operation is in-progress" {
	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q

	git bisect start

	run git pull-branches
	assert_failure
	assert_output --partial "cannot pull-branches"
}

@test "git pull-branches fails fast when cherry-pick operation is in-progress" {
	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q

	git_dir=$(git rev-parse --git-dir)
	git rev-parse HEAD >"$git_dir/CHERRY_PICK_HEAD"

	run git pull-branches
	assert_failure
	assert_output --partial "cannot pull-branches"
}

@test "git pull-branches fails fast when merge operation is in-progress" {
	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q

	git_dir=$(git rev-parse --git-dir)
	git rev-parse HEAD >"$git_dir/MERGE_HEAD"

	run git pull-branches
	assert_failure
	assert_output --partial "cannot pull-branches"
}

@test "git pull-branches fails fast when rebase operation is in-progress" {
	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q

	git_dir=$(git rev-parse --git-dir)
	git rev-parse HEAD >"$git_dir/REBASE_HEAD"

	run git pull-branches
	assert_failure
	assert_output --partial "cannot pull-branches"
}

@test "git pull-branches fails fast when rebase-apply operation is in-progress" {
	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q

	git_dir=$(git rev-parse --git-dir)
	mkdir -p "$git_dir/rebase-apply"

	run git pull-branches
	assert_failure
	assert_output --partial "cannot pull-branches"
}

@test "git pull-branches fails fast when rebase-merge operation is in-progress" {
	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q

	git_dir=$(git rev-parse --git-dir)
	mkdir -p "$git_dir/rebase-merge"

	run git pull-branches
	assert_failure
	assert_output --partial "cannot pull-branches"
}

@test "git pull-branches fails fast when revert operation is in-progress" {
	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q

	git_dir=$(git rev-parse --git-dir)
	git rev-parse HEAD >"$git_dir/REVERT_HEAD"

	run git pull-branches
	assert_failure
	assert_output --partial "cannot pull-branches"
}
