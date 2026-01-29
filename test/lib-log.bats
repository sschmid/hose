# shellcheck disable=SC1091,SC2034
setup() {
	load 'test_helper/bats-support/load.bash'
	load 'test_helper/bats-assert/load.bash'
	bats_require_minimum_version 1.5.0
	CLICOLOR=0
	source 'lib/log.bash'
}

@test "logs info" {
	run log_info "test"
	assert_success
	assert_output "[ info ] test"
}

@test "logs info done" {
	run log_info_done "test"
	assert_success
	assert_output "[ done ] test"
}

@test "logs divider" {
	run log_divider
	assert_success
	assert_output "--------------------------------------------------------------------------------"
}

@test "logs skip" {
	run log_skip "test"
	assert_success
	assert_output "[ skip ] test"
}

@test "logs warning" {
	run log_warn "test"
	assert_success
	assert_output "[ warn ] test"
}

@test "logs error" {
	run --separate-stderr log_error "test"
	assert_success
	refute_output
	assert_stderr "[ error ] test"
}

@test "logs fatal" {
	run --separate-stderr fatal "test"
	assert_failure
	refute_output
	assert_stderr "[ error ] test"
}

@test "logs checkmark check" {
	run log_checkmark_check "test"
	assert_success
	assert_output "[✓] test"
}

@test "logs checkmark cross" {
	run log_checkmark_cross "test"
	assert_success
	assert_output "[x] test"
}

@test "logs checkmark minus" {
	run log_checkmark_minus "test"
	assert_success
	assert_output "[-] test"
}
