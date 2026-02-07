# shellcheck disable=SC2034

check_systemctl_status() {
	status="$(sudo systemctl is-active "$1" 2>&1 || :):$(sudo systemctl is-enabled "$1" 2>&1 || :)"
	check "$1 $2" "$2"
}
