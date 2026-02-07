package_manager_install() {
	case "${HOSE_DISTRO}" in
		debian | raspbian) sudo apt-get install -y "$@" ;;
		fedora) sudo dnf install -y "$@" ;;
	esac
}
