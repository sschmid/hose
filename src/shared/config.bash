hose::config::load_hose() {
	hose::config::parse_section "hose" hose::config::hose_callback
}

hose::config::parse_section() {
	lib_config_parse_section "${HOSE_CONFIG}" "$1" "$2"
}

hose::config::declare_vars() {
	hose::config::parse_section "$1" hose::config::declare_var_callback
}

hose::config::declare_var_callback() {
	local section="$1" key="$2" value="$3"
	declare -n ref="config_${section}_${key}"
	# shellcheck disable=SC2034
	ref="${value}"
}

hose::config::hose_callback() {
	# shellcheck disable=SC2016
	case "$2" in
		ssh_pub_key)
			local value="$3"
			value="${value/'~'/"${HOME}"}"
			value="${value/'$HOME'/"${HOME}"}"
			value="${value/'${HOME}'/"${HOME}"}"
			hose::config::declare_var_callback "$1" "$2" "${value}"
		;;
		*) hose::config::declare_var_callback "$@" ;;
	esac
}
