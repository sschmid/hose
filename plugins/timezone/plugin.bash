about() {
	echo "Manages system timezone."
}

up() {
	sudo timedatectl set-timezone "${config_hose_timezone}"
}

status() {
	status="$(timedatectl show --property=Timezone --value)"
	check "timezone" "${config_hose_timezone}"
}
