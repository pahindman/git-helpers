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
