PLUGIN_NAME="plugin_1"

source "helper.bash"

about() {
	log "about $(whoami)@${HOSTNAME}"
}

info() {
	log "info $(whoami)@${HOSTNAME}"
}

up() {
	log "up $(whoami)@${HOSTNAME}"
}

down() {
	log "down $(whoami)@${HOSTNAME}"
}

status() {
	log "status $(whoami)@${HOSTNAME}"
}
