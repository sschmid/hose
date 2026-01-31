setup() {
	load 'test-helper.bash'
	load 'server-test-helper.bash'
	common_setup
	server_setup
	write_test_hose_config

	PLUGIN_COMMANDS=(
		a about
		i info
		u up
		d down
		s status
	)
}

teardown() {
	server_teardown
}

to_long_cmd() {
	local cmd="$1"
	case "$1" in
		a) cmd="about" ;;
		i) cmd="info" ;;
		u) cmd="up" ;;
		d) cmd="down" ;;
		s) cmd="status" ;;
	esac
	echo "${cmd}"
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

@test "syncs files" {
	run hose sync
	assert_success
	assert_output --partial "sending incremental file list"
	assert_output --partial ".env"
	assert_output --partial "test.conf"
	assert_output --partial "lib/"
	assert_output --partial "plugins/"
	assert_output --partial "src/"
}

@test "syncs and deletes files" {
	server_exec mkdir -p "${TEST_SERVER_HOSE_HOME}/lib"
	server_exec touch "${TEST_SERVER_HOSE_HOME}/lib/file.txt"

	run hose sync
	assert_success
	assert_output --partial "deleting lib/file.txt"
}

@test "logs quiet" {
	run hose -q sync
	assert_success
	refute_output --partial "[ info ] Syncing files"
}

@test "changes folder to config_hose_remote_path" {
	run hose server-env PWD
	assert_success
	assert_output --partial "declare -x PWD=\"${TEST_SERVER_HOSE_HOME}\""
}

@test "copies and sets HOSE_PLUGINS_HOME" {
	run hose server-env HOSE_PLUGINS_HOME
	assert_success
	assert_output --partial "declare -- HOSE_PLUGINS_HOME=\"${TEST_SERVER_HOSE_HOME}/${HOSE_PLUGINS_HOME##*/}\""

	run server_exec ls "${TEST_SERVER_HOSE_HOME}/${HOSE_PLUGINS_HOME##*/}"
	assert_success
	cat <<EOF | assert_output -
plugin-1
plugin-2
plugin-3
plugin-no-op
EOF
}

@test "copies and sets HOSE_CONFIG" {
	run hose server-env HOSE_CONFIG
	assert_success
	assert_output --partial "declare -- HOSE_CONFIG=\"${TEST_SERVER_HOSE_HOME}/${TEST_CONFIG##*/}\""

	run server_exec ls "${TEST_SERVER_HOSE_HOME}/${TEST_CONFIG##*/}"
	assert_success
	assert_output "${TEST_SERVER_HOSE_HOME}/${TEST_CONFIG##*/}"
}

@test "detects HOSE_DISTRO" {
	local image="${TEST_SERVER_BASE_IMAGE%:*}"
	run hose server-env HOSE_DISTRO
	assert_success
	assert_output --partial "declare -- HOSE_DISTRO=\"${image}\""
}

################################################################################
# plugins
################################################################################

@test "forwards command to all plugins" {
	local cmd
	for cmd in "${PLUGIN_COMMANDS[@]}"; do
		run hose "${cmd}"
		assert_success
		assert_output --partial "plugin-1 $(to_long_cmd "${cmd}") test@${TEST_SERVER_CONTAINER_ID}"
		assert_output --partial "plugin-2 $(to_long_cmd "${cmd}") test@${TEST_SERVER_CONTAINER_ID}"
	done
}

@test "forwards command to specified plugin" {
	for cmd in "${PLUGIN_COMMANDS[@]}"; do
		run hose "${cmd}" plugin-2
		assert_success
		refute_output --partial "plugin-1 $(to_long_cmd "${cmd}") test@${TEST_SERVER_CONTAINER_ID}"
		assert_output --partial "plugin-2 $(to_long_cmd "${cmd}") test@${TEST_SERVER_CONTAINER_ID}"
	done
}

@test "plugins may not implement commands" {
	for cmd in "${PLUGIN_COMMANDS[@]}"; do
		run hose "${cmd}" plugin-no-op
		assert_success
	done
}

@test "fails when specified plugin does not exist" {
	for cmd in "${PLUGIN_COMMANDS[@]}"; do
		run hose "${cmd}" unknown
		assert_server_fatal "Unknown plugin: unknown"
	done
}

@test "handles plugins config key does not exist" {
	write_config <<EOF
[hose]
user             = ${TEST_SERVER_USERNAME}
host             = ${TEST_SERVER_CONTAINER_IP_ADDRESS}
ssh_pub_key      = ${BATS_TEST_DIRNAME}/.ssh/hose-test.pub
remote_path      = /home/${TEST_SERVER_USERNAME}/hose
timezone         = Europe/Berlin
container_subnet = 10.11.12.0/24
EOF

	run hose about
	assert_success
}

@test "plugins can access config" {
	run hose up plugin-1
	assert_success
	assert_output --partial "[ info ] From hose config: ${TEST_SERVER_USERNAME}@${TEST_SERVER_CONTAINER_IP_ADDRESS}"
	assert_output --partial "plugin-1 up ${TEST_SERVER_USERNAME}@${TEST_SERVER_CONTAINER_ID}"
}

@test "logs to file" {
	count_files() {
		server_exec ls "/home/${TEST_SERVER_USERNAME}/.local/state/hose/logs" | wc -l | xargs
	}

	hose -q  up plugin-1
	run count_files
	assert_success
	assert_output "1"

	sleep 2 # Ensure different timestamp

	hose -q  up plugin-1
	run count_files
	assert_success
	assert_output "2"
}
