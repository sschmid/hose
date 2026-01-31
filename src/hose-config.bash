hose::config::print_all_callback() {
	if [[ "$1" != "${HOSE_CONFIG_CURRENT_SECTION}" ]]; then
		HOSE_CONFIG_CURRENT_SECTION="$1"
		printf "%s[%s]%s\n" "${COLOR_GREEN}" "${HOSE_CONFIG_CURRENT_SECTION}" "${COLOR_RESET}"
	fi
	lib_config_print_kv "$@"
}

hose::config::print_plugins() {
	local -a all_plugins=()
	local -A all_plugins_lookup=()
	local -A selected_plugins_lookup=()

	local plugin
	while IFS= read -r plugin; do
		plugin="${plugin##*/}"
		all_plugins+=("${plugin}")
		all_plugins_lookup["${plugin}"]=1
	done < <(find "${HOSE_PLUGINS_HOME}" -maxdepth 1 -mindepth 1 -type d | LC_ALL=C sort)

	check_plugin_callback() {
		[[ "$2" == "plugins" ]] || return 0
		local plugin_entry
		for plugin_entry in $3; do
			if [[ -v all_plugins_lookup["${plugin_entry}"] ]]; then
				selected_plugins_lookup["${plugin_entry}"]=1
				printf "%s[✓]%s %s\n" "${COLOR_GREEN}" "${COLOR_RESET}" "${plugin_entry}"
			else
				printf "%s[x]%s %s\n" "${COLOR_RED}" "${COLOR_RESET}" "${plugin_entry}"
			fi
		done
	}

	hose::config::parse_section "hose" check_plugin_callback

	for plugin in "${all_plugins[@]}"; do
		[[ -v selected_plugins_lookup["${plugin}"] ]] || printf "%s[-]%s %s\n" "${COLOR_ORANGE}" "${COLOR_RESET}" "${plugin}"
	done
}

hose::config::print() {
	[[ -f "${HOSE_CONFIG}" ]] || fatal "${PROGRAM}: Config file not found: ${HOSE_CONFIG}"

	local cmd="$1"; shift
	case "${cmd}" in
		config)
			if (( ! $# )); then
				HOSE_CONFIG_CURRENT_SECTION=""
				hose::config::parse_section "" hose::config::print_all_callback
			else
				hose::config::parse_section "$1" lib_config_print_kv
			fi
			;;
		plugins)
			hose::config::print_plugins
			;;
	esac
}

hose::config::print "$@"
