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
	export PATH="$BATS_TEST_DIRNAME/..:$BATS_TEST_DIRNAME/../lib/bash-helpers:$PATH"
}

teardown() {
	cd "$BATS_TEST_DIRNAME" || return 1
}

# bats file_tags=pull-branches

@test "git pull-branches succeeds on a clean repository" {
	git init -q --bare "$BATS_TEST_TMPDIR/remote.git"
	git remote add origin "$BATS_TEST_TMPDIR/remote.git"
	git checkout -b main

	echo base > tracked.txt
	git add tracked.txt
	git commit -m "initial" -q
	git push -u origin main -q

	run git pull-branches
	assert_success
}

@test "git pull-branches rejects a dirty worktree" {
	echo base > tracked.txt
	git add tracked.txt
	git commit -m "initial" -q

	echo dirty >> tracked.txt

	run git pull-branches
	assert_failure
	assert_output --partial "unstaged changes"
}

@test "git pull-branches --dry-run prints branches without changing state" {
	git init -q --bare "$BATS_TEST_TMPDIR/remote.git"
	git remote add origin "$BATS_TEST_TMPDIR/remote.git"
	git checkout -b main

	echo base > tracked.txt
	git add tracked.txt
	git commit -m "initial" -q
	git push -u origin main -q

	git checkout -b feature
	echo feature >> tracked.txt
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
