setup() {
	load 'test-helper.bash'
	load 'server-test-helper.bash'
	common_setup
	server_setup
}

teardown() {
	server_teardown
}

@test "execs in server container" {
	run server_exec whoami
	assert_success
	assert_output "${TEST_SERVER_USERNAME}"
}

@test "can ssh into server container" {
	run ssh -p "${TEST_SERVER_SSH_PORT}" "${TEST_SERVER_USERNAME}@${TEST_SERVER_CONTAINER_IP_ADDRESS}" echo "test message"
	assert_success
	assert_output --partial "test message"
}
