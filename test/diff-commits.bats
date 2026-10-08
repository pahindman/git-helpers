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

# bats file_tags=diff-commits

@test "git diff-commits compares two commits" {
	git config diff.tool fake
	git config difftool.fake.cmd "true"

	echo first >foo.txt
	git add foo.txt
	git commit -m "first" -q

	echo second >>foo.txt
	git add foo.txt
	git commit -m "second" -q

	first=$(git rev-parse HEAD~1)
	second=$(git rev-parse HEAD)

	run git diff-commits "$first" "$second"
	assert_failure
}

@test "git diff-commits succeeds when the revisions are identical" {
	git config diff.tool fake
	git config difftool.fake.cmd "true"

	echo hello >foo.txt
	git add foo.txt
	git commit -m "initial" -q

	sha=$(git rev-parse HEAD)
	run git diff-commits "$sha" "$sha"
	assert_success
}
