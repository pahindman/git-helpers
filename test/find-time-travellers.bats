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

# bats file_tags=find-time-travellers

@test "git find-time-travellers identifies commits with a large date drift" {
	GIT_AUTHOR_DATE="2020-01-01T12:00:00Z" GIT_COMMITTER_DATE="2025-01-20T12:00:00Z" git commit --allow-empty -m "time travel" -q

	run git find-time-travellers -d 14 HEAD
	assert_success
	assert_output --partial "time travel"
}

@test "git find-time-travellers does not report ordinary commits" {
	# Create a normal commit where the author and committer dates are the same day.
	GIT_AUTHOR_DATE="2025-01-10T12:00:00Z" GIT_COMMITTER_DATE="2025-01-10T12:00:00Z" git commit --allow-empty -m "normal commit" -q

	run git find-time-travellers -d 14 HEAD
	assert_success
	refute_output --partial "normal commit"
}
