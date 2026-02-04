about() {
	echo "Checks root account lock status."
}

status() {
	status="$(sudo passwd -S root)"
	check_regex "root account locked" '^root L'
}
