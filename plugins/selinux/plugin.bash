about() {
	echo "Checks if SELinux is in enforcing mode."
}

status() {
	if command -v getenforce &>/dev/null; then
		status="$(getenforce)"
		check "SELinux enforcing" "Enforcing"
	else
		check_skip "getenforce command not found"
	fi
}
