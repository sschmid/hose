server_setup() {
	if (( ! TEST_HAS_SERVER )); then
		skip "Skipping server tests"
		return
	fi

	export TEST_SERVER_SSH_PORT=2234
	TEST_SERVER_CONTAINER_ID="$(test/container-cmd run --rm -d -p ${TEST_SERVER_SSH_PORT}:22 "${TEST_SERVER_IMAGE}")"
	TEST_SERVER_CONTAINER_ID="${TEST_SERVER_CONTAINER_ID:0:8}"
	export TEST_SERVER_CONTAINER_ID
	export TEST_SERVER_CONTAINER_IP_ADDRESS="127.0.0.1"

	echo -e "\033[0;36m[ $(test/container-cmd) ]\033[0m Starting ${TEST_SERVER_IMAGE} ${TEST_SERVER_CONTAINER_ID} ${TEST_SERVER_CONTAINER_IP_ADDRESS}" >&3

	export -f ssh
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

ssh() {
	command ssh \
		-i test/.ssh/hose-test \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-p "${TEST_SERVER_SSH_PORT}" \
		"$@"
}
