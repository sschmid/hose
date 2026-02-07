about() {
	echo "Manages package updates and upgrades."
}

case "${HOSE_DISTRO}" in
	debian | raspbian)
		add_root_file "files/999hose-package_manager" \
			"/etc/apt/apt.conf.d/999hose-package_manager" \
			config_package_manager_apt_install_recommends \
			config_package_manager_apt_install_suggests

		add_root_file "files/debian-backports.sources" \
			"/etc/apt/sources.list.d/debian-backports.sources"
	;;
	fedora)
		add_root_file "files/dnf.conf" \
			"/etc/dnf/dnf.conf" \
			config_package_manager_dnf_max_parallel_downloads \
			config_package_manager_dnf_install_weak_deps
	;;
esac

up() {
	write_root_files

	case "${HOSE_DISTRO}" in
		debian | raspbian)
			sudo apt-get upgrade -y
			sudo apt-get autoremove -y
		;;
		fedora)
			sudo dnf upgrade -y
			sudo dnf autoremove -y
		;;
	esac
}

down() {
	delete_root_files
}

status() {
	check_root_files

	case "${HOSE_DISTRO}" in
		debian | raspbian)
			status="$(apt-get -s upgrade | grep '^Inst' || :)"
			check "apt upgrade" ""
		;;
		fedora)
			status="$(dnf check-upgrade 2>/dev/null || :)"
			check "dnf upgrade" ""
		;;
	esac
}
