setup() {
	load 'test-helper.bash'
	common_setup
}

assert_usage() {
	assert_output --partial "usage: ${PROGRAM}"
}

@test "fails when no command arguments are given" {
	run "${PROGRAM}"
	assert_failure
	assert_usage
}

@test "prints help" {
	run "${PROGRAM}" -h
	assert_success
	assert_usage
}

@test "fails when invalid option is given" {
	run --separate-stderr "${PROGRAM}" -x
	assert_fatal "${PROGRAM}: Invalid option: -x"
}

@test "uses default hose.conf if none is specified" {
	unset HOSE_CONFIG
	run "${PROGRAM}" env "HOSE_CONFIG"
	assert_success
	assert_output "declare -- HOSE_CONFIG=\"${PWD}/hose.conf\""
}

@test "uses TEST_CONFIG" {
	run "${PROGRAM}" env "HOSE_CONFIG"
	assert_success
	assert_output "declare -x HOSE_CONFIG=\"${TEST_CONFIG}\""
}

@test "uses specified config file (realtive path)" {
	run "${PROGRAM}" -c "test.conf" env "HOSE_CONFIG"
	assert_success
	assert_output "declare -x HOSE_CONFIG=\"${PWD}/test.conf\""
}

@test "uses specified config file (absolute path)" {
	run "${PROGRAM}" -c "${BATS_TEST_TMPDIR}/test.conf" env "HOSE_CONFIG"
	assert_success
	assert_output "declare -x HOSE_CONFIG=\"${BATS_TEST_TMPDIR}/test.conf\""
}

@test "fails when no command argument is given after options" {
	run "${PROGRAM}" -c "test.conf"
	assert_failure
	assert_usage
}

@test "fails when unknown command is given" {
	run --separate-stderr "${PROGRAM}" unknown
	assert_fatal "${PROGRAM}: Unknown command: unknown"
}
