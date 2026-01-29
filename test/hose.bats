setup() {
	load 'test-helper.bash'
	common_setup
}

@test "fails" {
	run hose
	assert_success
	refute_output
}

@test "passes" {
	run hose
	assert_success
	assert_output "hose"
}
