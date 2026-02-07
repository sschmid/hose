PLUGIN_NAME="plugin_1"

source "helper.bash"

placeholder1="replaced 1"
placeholder2="replaced 2"

sudo mkdir -p "/etc/${PLUGIN_NAME}"
add_root_file "files/file1.txt" "/etc/${PLUGIN_NAME}/file1.txt"
add_root_file "files/file2.txt" "/etc/${PLUGIN_NAME}/file2.txt"
add_root_file "files/file3.txt" "/etc/${PLUGIN_NAME}/file3.txt" placeholder1 placeholder2

about() {
	log "about $(whoami)@${HOSTNAME}"
}

info() {
	log "info $(whoami)@${HOSTNAME}"
}

up() {
	log "up $(whoami)@${HOSTNAME}"
	write_root_files
}

down() {
	log "down $(whoami)@${HOSTNAME}"
}

status() {
	log "status $(whoami)@${HOSTNAME}"
}
