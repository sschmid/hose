fatal() {
	log_error "$@"
	exit 1
}

log_info()      { (( LOG_QUIET )) || printf "%s[ info ]%s %s\n"   "${COLOR_CYAN}"   "${COLOR_RESET}" "$*"     ; }
log_info_done() { (( LOG_QUIET )) || printf "%s[ done ]%s %s\n\n" "${COLOR_GREEN}"  "${COLOR_RESET}" "$*"     ; }
log_divider()   { (( LOG_QUIET )) || printf "%s--------------------------------------------------------------------------------%s\n" "${COLOR_BLUE}" "${COLOR_RESET}"; }

log_skip()  { printf "%s[ skip ]%s %s\n"   "${COLOR_ORANGE}" "${COLOR_RESET}" "$*"     ; }
log_warn()  { printf "%s[ warn ]%s %s\n"   "${COLOR_ORANGE}" "${COLOR_RESET}" "$*"     ; }
log_error() { printf "%s[ error ]%s %s\n"  "${COLOR_RED}"    "${COLOR_RESET}" "$*" >&2 ; }

log_checkmark_check() { printf "%s[✓]%s %s\n" "${COLOR_GREEN}"  "${COLOR_RESET}" "$*" ; }
log_checkmark_cross() { printf "%s[x]%s %s\n" "${COLOR_RED}"    "${COLOR_RESET}" "$*" ; }
log_checkmark_minus() { printf "%s[-]%s %s\n" "${COLOR_ORANGE}" "${COLOR_RESET}" "$*" ; }
