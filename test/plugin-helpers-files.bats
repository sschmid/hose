setup() {
	load 'test-helper.bash'
	load 'server-test-helper.bash'
	common_setup
	server_setup
	write_test_hose_config
}

teardown() {
	server_teardown
}

@test "writes a root file" {
	run hose up plugin_1
	assert_success
	assert_root_file "/etc/plugin_1/file1.txt"

	run server_exec cat "/etc/plugin_1/file1.txt"
	assert_success
	assert_output "plugin_1 file1.txt"
}

@test "writes multiple root files" {
	run hose up plugin_1
	assert_success
	assert_root_file "/etc/plugin_1/file1.txt"
	assert_root_file "/etc/plugin_1/file2.txt"

	run server_exec cat "/etc/plugin_1/file1.txt"
	assert_success
	assert_output "plugin_1 file1.txt"

	run server_exec cat "/etc/plugin_1/file2.txt"
	assert_success
	assert_output "plugin_1 file2.txt"
}

@test "replaces placeholders" {
	run hose up plugin_1
	assert_success
	assert_root_file "/etc/plugin_1/file3.txt"

	run server_exec cat "/etc/plugin_1/file3.txt"
	assert_success
	assert_output "plugin_1 file3.txt replaced 1 replaced 2"
}
