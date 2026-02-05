# shellcheck disable=SC2154
log_check_pass() {
	printf "%s[ pass ] %s%s%s: %s\n" "${COLOR_GREEN}" "${COLOR_BLUE}" "${plugin##*/}" "${COLOR_RESET}" "$1"
}

log_check_fail() {
	printf "%s[ fail ] %s%s%s: %s " "${COLOR_RED}" "${COLOR_BLUE}" "${plugin##*/}" "${COLOR_RESET}" "$1" >&2
	diff -u <(echo "$2") <(echo "${status}") \
		| delta --pager=never --file-style=omit --hunk-header-style=omit >&2 || :
}

check_skip() {
	printf "%s[ skip ] %s%s%s: %s\n" "${COLOR_ORANGE}" "${COLOR_BLUE}" "${plugin##*/}" "${COLOR_RESET}" "$1"
}

check() {
	if [[ "${status}" == "$2" ]]
	then log_check_pass "$1"
	else log_check_fail "$1" "$2"
	fi
}

check_regex() {
	if [[ "${status}" =~ $2 ]]
	then log_check_pass "$1"
	else log_check_fail "$1" "$2"
	fi
}
