setup() {
	load 'test-helper.bash'
	common_setup
}

@test "passes" {
	run hose
	assert_success
	assert_output "hose"
}
