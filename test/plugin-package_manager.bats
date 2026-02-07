setup() {
	load 'test-helper.bash'
	load 'server-test-helper.bash'
	common_setup
	plugin_setup "package_manager"
	IMAGE="${TEST_SERVER_BASE_IMAGE%:*}"
}

teardown() {
	server_teardown
}

@test "writes files" {
	run hose up package_manager
	assert_success

	case "${IMAGE}" in
		debian | raspbian)
			assert_root_file "/etc/apt/apt.conf.d/999hose-package_manager"
			assert_root_file "/etc/apt/sources.list.d/debian-backports.sources"
		;;
		fedora)
			assert_root_file "/etc/dnf/dnf.conf"
		;;
	esac
	}
