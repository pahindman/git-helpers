setup() {
	load 'test_helper/bats-support/load'
	load 'test_helper/bats-assert/load'

	# Create a dedicated temp folder for the current test
	TEST_REPO="$BATS_TEST_TMPDIR/test-repo"
	mkdir -p "$TEST_REPO"
	cd "$TEST_REPO" || return 1

	# Initialize a fresh git repository on a stable default branch
	git init -q -b main
	git config user.name "Test User"
	git config user.email "test@example.com"

	# Add your Git subcommand directory and the bash-helpers library to PATH so the
	# sourced getopt helper and local scripts resolve during tests.
	export PATH="$BATS_TEST_DIRNAME/..:$BATS_TEST_DIRNAME/../lib/bash-helpers:$PATH"
}

teardown() {
	# $BATS_TEST_TMPDIR is automatically cleaned up by bats-core,
	# but cd out of the directory to prevent locking issues
	cd "$BATS_TEST_DIRNAME" || return 1
}

# bats file_tags=cleanup-branches

@test "git cleanup-branches deletes the merged branch" {
	# Set up dummy state
	touch foo.txt
	git add foo.txt
	git commit -m "Initial commit" -q
	git checkout -b deleted-branch
	git checkout -b unmerged-branch
	touch bar.txt
	git add bar.txt
	git commit -m "Unmerged commit" -q

	run bash -c "printf 'y\n' | git cleanup-branches main"
	assert_success

	# Check that the merged branch was deleted
	run git branch --format='%(refname:short)'
	assert_success
	refute_output --partial "deleted-branch"
}

@test "git cleanup-branches leaves the unmerged branch" {
	# # Set up dummy state
	touch foo.txt
	git add foo.txt
	git commit -m "Initial commit" -q
	git checkout -b merged-branch
	git checkout -b unmerged-branch
	touch bar.txt
	git add bar.txt
	git commit -m "Unmerged commit" -q

	run bash -c "printf 'y\n' | git cleanup-branches main"
	assert_success

	# Check that the unmerged branch still exists
	run git branch --format='%(refname:short)'
	assert_success
	assert_output --partial "unmerged-branch"
}

@test "git cleanup-branches --dry-run reports branches without deleting them" {
	touch foo.txt
	git add foo.txt
	git commit -m "Initial commit" -q
	git checkout -b merged-branch
	git checkout -b unmerged-branch
	touch bar.txt
	git add bar.txt
	git commit -m "Unmerged commit" -q

	run git cleanup-branches --dry-run main
	assert_success
	assert_output --partial "Would delete merged-branch"
	refute_output --partial "Would delete unmerged-branch"

	run git branch --format='%(refname:short)'
	assert_success
	assert_output --partial "merged-branch"
}
