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

# bats file_tags=diff-staged-vs

@test "git diff-staged-vs compares staged changes against HEAD" {
	git config diff.tool fake
	git config difftool.fake.cmd "true"

	echo base >tracked.txt
	git add tracked.txt
	git commit -m "base" -q

	echo staged >>tracked.txt
	git add tracked.txt

	run git diff-staged-vs HEAD
	assert_failure
}

@test "git diff-staged-vs compares staged changes against an explicit ref" {
	git config diff.tool fake
	git config difftool.fake.cmd "true"

	echo base >tracked.txt
	git add tracked.txt
	git commit -m "base" -q

	git checkout -b feature
	echo feature >>tracked.txt
	git add tracked.txt
	git commit -m "feature" -q

	echo staged >>tracked.txt
	git add tracked.txt

	run git diff-staged-vs HEAD~1
	assert_failure
}
