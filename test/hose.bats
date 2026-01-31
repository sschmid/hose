setup() {
	load 'test-helper.bash'
	common_setup
}

assert_usage() {
	assert_output --partial "usage: ${PROGRAM}"
}

@test "fails when no command arguments are given" {
	run hose
	assert_failure
	assert_usage
}

@test "prints help" {
	run hose -h
	assert_success
	assert_usage
}

@test "fails when invalid option is given" {
	run --separate-stderr hose -x
	assert_fatal "${PROGRAM}: Invalid option: -x"
}

@test "uses default hose.conf if none is specified" {
	unset HOSE_CONFIG
	run hose env "HOSE_CONFIG"
	assert_success
	assert_output "declare -- HOSE_CONFIG=\"${PWD}/hose.conf\""
}

@test "uses TEST_CONFIG" {
	run hose env "HOSE_CONFIG"
	assert_success
	assert_output "declare -x HOSE_CONFIG=\"${TEST_CONFIG}\""
}

@test "uses specified config file (relative path)" {
	run hose -c "test.conf" env "HOSE_CONFIG"
	assert_success
	assert_output "declare -x HOSE_CONFIG=\"${PWD}/test.conf\""
}

@test "uses specified config file (absolute path)" {
	run hose -c "${BATS_TEST_TMPDIR}/test.conf" env "HOSE_CONFIG"
	assert_success
	assert_output "declare -x HOSE_CONFIG=\"${BATS_TEST_TMPDIR}/test.conf\""
}

@test "fails when no command argument is given after options" {
	run hose -c "test.conf"
	assert_failure
	assert_usage
}

@test "fails when unknown command is given" {
	run --separate-stderr hose unknown
	assert_fatal "${PROGRAM}: Unknown command: unknown"
}

@test "uses default HOSE_PLUGINS_HOME" {
	unset HOSE_PLUGINS_HOME
	run hose env "HOSE_PLUGINS_HOME"
	assert_success
	assert_output "declare -- HOSE_PLUGINS_HOME=\"${PWD}/plugins\""
}

@test "reads HOSE_PLUGINS_HOME from env" {
	run hose env "HOSE_PLUGINS_HOME"
	assert_success
	assert_output "declare -x HOSE_PLUGINS_HOME=\"${BATS_TEST_DIRNAME}/fixtures/plugins\""
}

@test "fails when HOSE_PLUGINS_HOME does not exist" {
	export HOSE_PLUGINS_HOME="${BATS_TEST_TMPDIR}/unknown"
	run --separate-stderr hose env "HOSE_PLUGINS_HOME"
	assert_fatal "hose: Plugins directory does not exist: ${HOSE_PLUGINS_HOME}"
}
