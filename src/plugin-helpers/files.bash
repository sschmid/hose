# shellcheck disable=SC2034

check_file_content() {
	status="$(sudo cat "$1" 2>&1 || :)"
	check "$1" "$2"
}

check_root_files() {
	local path
	for path in "${!root_files[@]}"; do
		check_file_content "${path}" "${root_files[${path}]}"
	done
}

add_root_file() {
	local src="$1" dest="$2"; shift 2
	local content
	if (( $# )); then
		local -a sed_args=()
		local __plugin_placeholder
		for __plugin_placeholder in "$@"; do
			sed_args+=(-e "s|\${${__plugin_placeholder}}|${!__plugin_placeholder}|g")
		done
		content="$(sed "${sed_args[@]}" "${src}")"
	else
		content="$(cat "${src}")"
	fi

	root_files["${dest}"]="${content}"
}

write_root_files() {
	local path file_content diff
	for path in "${!root_files[@]}"; do
		file_content="${root_files[${path}]}"
		if sudo test -f "${path}"; then
			if ! diff="$(diff -u <(sudo cat "${path}") <(echo "${file_content}") \
					| delta --pager=never --file-style=omit --hunk-header-style=omit)"
			then
				log_info "Diff for existing ${path}:${diff}"
			fi
		fi

		log_info "Writing ${path}"
		sudo tee "${path}" >/dev/null <<< "${file_content}"
	done
}

delete_root_files() {
	local path
	for path in "${!root_files[@]}"; do
		sudo rm -vf "${path}"
	done
}
