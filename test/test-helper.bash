# shellcheck disable=SC2034
common_setup() {
	load 'test_helper/bats-support/load.bash'
	load 'test_helper/bats-assert/load.bash'
	bats_require_minimum_version 1.5.0

	PROJECT_ROOT="${BATS_TEST_DIRNAME}/.."
	PATH="${PROJECT_ROOT}/src:${PATH}"

	PROGRAM="hose"

	TEST_CONFIG="${BATS_TEST_TMPDIR}/test.conf"
	write_config <<< "test_key = test value"

	export HOSE_PLUGINS_HOME="${BATS_TEST_DIRNAME}/fixtures/plugins"
	export HOSE_CONFIG="${TEST_CONFIG}"
}

write_config() {
	cat > "${TEST_CONFIG}"
}

append_config() {
	cat >> "${TEST_CONFIG}"
}

assert_fatal() {
	assert_failure
	assert_output "${2:-}"
	assert_stderr "[ error ] $1"
}
