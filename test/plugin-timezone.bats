setup() {
	load 'test-helper.bash'
	load 'server-test-helper.bash'
	common_setup
	plugin_setup "timezone"
}

teardown() {
	server_teardown
}

@test "status pass" {
	server_mock "timedatectl" "echo 'Europe/Berlin'"
	run hose -q status timezone
	assert_check_pass "timezone"
}

@test "status fail" {
	server_mock "timedatectl" "echo 'Wrong/Timezone'"
	run hose -q status timezone
	assert_check_fail "timezone"
}
