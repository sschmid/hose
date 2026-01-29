common_setup() {
	load 'test_helper/bats-support/load.bash'
	load 'test_helper/bats-assert/load.bash'

	PROJECT_ROOT="${BATS_TEST_DIRNAME}/.."
	PATH="${PROJECT_ROOT}/src:${PATH}"
}
