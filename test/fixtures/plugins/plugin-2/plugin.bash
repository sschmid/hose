PLUGIN_NAME="plugin-2"

about() {
	echo "${PLUGIN_NAME} about $(whoami)@${HOSTNAME}"
}

info() {
	echo "${PLUGIN_NAME} info $(whoami)@${HOSTNAME}"
}

up() {
	echo "${PLUGIN_NAME} up $(whoami)@${HOSTNAME}"
}

down() {
	echo "${PLUGIN_NAME} down $(whoami)@${HOSTNAME}"
}

status() {
	echo "${PLUGIN_NAME} status $(whoami)@${HOSTNAME}"
}
