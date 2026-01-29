setup_suite() {
	(( TEST_IS_DISTRO_CONTAINER )) && return

	export TEST_HAS_SERVER=1
	export TEST_SERVER_USERNAME="test"
	export TEST_SERVER_HOSE_HOME="/home/${TEST_SERVER_USERNAME}/hose"

	local image="${TEST_SERVER_BASE_IMAGE%:*}"
	local tag="${TEST_SERVER_BASE_IMAGE##*:}"
	export TEST_SERVER_IMAGE="hose/test/server/${image}/${tag}"

	echo -e "\033[0;36m[ $(test/container-cmd) ]\033[0m Building ${TEST_SERVER_IMAGE} image..." >&3

	test/container-cmd build \
		--target server \
		--tag "${TEST_SERVER_IMAGE}" \
		--build-arg IMAGE="${image}" \
		--build-arg TAG="${tag}" \
		--build-arg USERNAME="${TEST_SERVER_USERNAME}" \
		--file "${BATS_TEST_DIRNAME}/Containerfile.TestServer" \
		"${BATS_TEST_DIRNAME}" >&3

	chmod 600 test/.ssh/hose-test
	chmod 644 test/.ssh/hose-test.pub
	chmod 700 test/.ssh
}
