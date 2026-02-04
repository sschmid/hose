for file in src/plugin-helpers/*.bash; do
	# shellcheck disable=SC1090
	[[ "$(basename -- "${file}")" == "all.bash" ]] || source "${file}"
done
