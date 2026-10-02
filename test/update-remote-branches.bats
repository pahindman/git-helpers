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

# bats file_tags=update-remote-branches

@test "git update-remote-branches pushes a branch with local commits" {
	git init -q --bare "$BATS_TEST_TMPDIR/remote.git"
	git remote add origin "$BATS_TEST_TMPDIR/remote.git"
	git checkout -b main

	echo base > tracked.txt
	git add tracked.txt
	git commit -m "initial" -q
	git push -u origin main -q

	echo local >> tracked.txt
	git add tracked.txt
	git commit -m "local change" -q

	run git update-remote-branches
	assert_success
	assert_output --partial "Pushed main to origin"
}

@test "git update-remote-branches skips branches with no remote tracking ref" {
	git init -q --bare "$BATS_TEST_TMPDIR/remote.git"
	git remote add origin "$BATS_TEST_TMPDIR/remote.git"
	git checkout -b main

	echo base > tracked.txt
	git add tracked.txt
	git commit -m "initial" -q
	git push -u origin main -q

	git checkout -b feature
	echo local >> tracked.txt
	git add tracked.txt
	git commit -m "local branch" -q

	run git update-remote-branches
	assert_success
	refute_output --partial "Pushed feature to origin"
}
