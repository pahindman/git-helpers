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

# bats file_tags=status-push

@test "git status-push reports a branch that is ahead of its push remote" {
	git init -q --bare "$BATS_TEST_TMPDIR/remote.git"
	git remote add origin "$BATS_TEST_TMPDIR/remote.git"

	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q
	git push -u origin HEAD:main -q

	git checkout -b feature
	echo feature >>tracked.txt
	git add tracked.txt
	git commit -m "feature" -q
	git push -u origin feature -q

	echo more >>tracked.txt
	git add tracked.txt
	git commit -m "ahead" -q

	run git status-push
	assert_success
	assert_output --partial "feature"
	assert_output --partial "ahead"
}

@test "git status-push reports an up-to-date branch" {
	git init -q --bare "$BATS_TEST_TMPDIR/remote.git"
	git remote add origin "$BATS_TEST_TMPDIR/remote.git"

	echo base >tracked.txt
	git add tracked.txt
	git commit -m "initial" -q
	git push -u origin HEAD:main -q

	run git status-push
	assert_success
	assert_output --partial "main"
	assert_output --partial "up to date"
}
