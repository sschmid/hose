setup() {
	load 'test-helper.bash'
	load 'server-test-helper.bash'
	common_setup
	plugin_setup "selinux"
}

teardown() {
	server_teardown
}

@test "status pass" {
	server_mock "getenforce" "echo 'Enforcing'"
	run hose -q status selinux
	assert_check_pass "SELinux enforcing"
}

@test "status fail" {
	server_mock "getenforce" "echo 'Permissive'"
	run hose -q status selinux
	assert_check_fail "SELinux enforcing"
}
