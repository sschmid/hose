log_info "From hose config: ${config_hose_user}@${config_hose_host}"
log_info "From plugin config: key1 = ${config_plugin_1_key1}"
log_info "From plugin config: key2 = ${config_plugin_1_key2}"

log() {
	echo "${PLUGIN_NAME} $*"
}
