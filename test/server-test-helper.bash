# shellcheck disable=SC2034
server_setup() {
	if (( ! TEST_HAS_SERVER )); then
		skip "Skipping server tests"
		return
	fi

	PROGRAM="hose-server"
	export CLICOLOR=0

	export TEST_SERVER_SSH_PORT=2234
	TEST_SERVER_CONTAINER_ID="$(test/container-cmd run --rm -d -p ${TEST_SERVER_SSH_PORT}:22 "${TEST_SERVER_IMAGE}")"
	TEST_SERVER_CONTAINER_ID="${TEST_SERVER_CONTAINER_ID:0:8}"
	export TEST_SERVER_CONTAINER_ID
	export TEST_SERVER_CONTAINER_IP_ADDRESS="127.0.0.1"

	echo -e "\033[0;36m[ $(test/container-cmd) ]\033[0m Starting ${TEST_SERVER_IMAGE} ${TEST_SERVER_CONTAINER_ID} ${TEST_SERVER_CONTAINER_IP_ADDRESS}" >&3

	# command overwrite
	export -f ssh-copy-id
	export -f ssh
	export -f rsync
}

plugin_setup() {
	PLUGIN="$1"
	server_setup
	unset HOSE_PLUGINS_HOME
	write_config <<EOF
[hose]
user             = ${TEST_SERVER_USERNAME}
host             = ${TEST_SERVER_CONTAINER_IP_ADDRESS}
ssh_pub_key      = ${BATS_TEST_DIRNAME}/.ssh/hose-test.pub
remote_path      = /home/${TEST_SERVER_USERNAME}/hose
timezone         = Europe/Berlin
container_subnet = 10.11.12.0/24
plugins          = ${PLUGIN}
EOF
}

server_teardown() {
	if (( ! TEST_HAS_SERVER )); then
		return
	fi

	echo -e "\033[0;36m[ $(test/container-cmd) ]\033[0m Stopping ${TEST_SERVER_IMAGE} ${TEST_SERVER_CONTAINER_ID}" >&3
	test/container-cmd stop "${TEST_SERVER_CONTAINER_ID}"
	unset TEST_SERVER_CONTAINER_ID
	unset TEST_SERVER_CONTAINER_IP_ADDRESS
}

server_exec() {
	test/container-cmd exec "${TEST_SERVER_CONTAINER_ID}" "$@"
}

write_test_hose_config() {
	write_config <<EOF
[hose]
user             = ${TEST_SERVER_USERNAME}
host             = ${TEST_SERVER_CONTAINER_IP_ADDRESS}
ssh_pub_key      = ${BATS_TEST_DIRNAME}/.ssh/hose-test.pub
remote_path      = /home/${TEST_SERVER_USERNAME}/hose
timezone         = Europe/Berlin
container_subnet = 10.11.12.0/24
plugins          = plugin-1 \\
                   plugin-2
EOF
}

assert_check_pass() {
	assert_success
	assert_output --partial "[ pass ] ${PLUGIN}: $1"
}

assert_check_fail() {
	assert_success
	assert_output --partial "[ fail ] ${PLUGIN}: $1"
}

assert_check_skip() {
	assert_success
	assert_output --partial "[ skip ] ${PLUGIN}: $1"
}

server_mock() {
	server_exec sudo bash -c "echo '$2' > \"/usr/local/bin/$1\""
	server_exec sudo chmod +x "/usr/local/bin/$1"
}

################################################################################
# command overwrite
################################################################################

ssh-copy-id() {
	command ssh-copy-id -p "${TEST_SERVER_SSH_PORT}" "$@"
}

ssh() {
	command ssh \
		-i test/.ssh/hose-test \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-p "${TEST_SERVER_SSH_PORT}" \
		"$@"
}

rsync() {
	local -a args=("$@")
	local -i i
	for i in "${!args[@]}"; do
		if [[ "${args[i]}" == "-e" && "${args[i+1]}" == "ssh" ]]; then
			args[i+1]="ssh -i test/.ssh/hose-test -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${TEST_SERVER_SSH_PORT}"
			break
		fi
	done
	command rsync "${args[@]}"
}

assert_server_fatal() {
	assert_failure
	assert_output --partial "[ error ] ${PROGRAM}: $1"
}
