setup() {
	load 'test-helper.bash'
	load 'server-test-helper.bash'
	common_setup
	plugin_setup "root"
}

teardown() {
	server_teardown
}

@test "status pass" {
	run hose -q status root
	assert_check_pass "root account locked"
}

@test "status fail" {
	server_mock "passwd" "echo 'root P 2020-01-01 0 99999 7 -1'"
	run hose -q status root
	assert_check_fail "root account locked"
}
