PLUGIN_NAME="plugin_2"

sudo mkdir -p "/etc/${PLUGIN_NAME}"
add_root_file "files/file1.txt" "/etc/${PLUGIN_NAME}/file1.txt"
add_root_file "files/file2.txt" "/etc/${PLUGIN_NAME}/file2.txt"

about() {
	echo "${PLUGIN_NAME} about $(whoami)@${HOSTNAME}"
}

info() {
	echo "${PLUGIN_NAME} info $(whoami)@${HOSTNAME}"
}

up() {
	echo "${PLUGIN_NAME} up $(whoami)@${HOSTNAME}"
	write_root_files
}

down() {
	echo "${PLUGIN_NAME} down $(whoami)@${HOSTNAME}"
}

status() {
	echo "${PLUGIN_NAME} status $(whoami)@${HOSTNAME}"
}
