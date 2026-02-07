iface="$(ip route show default | awk '{print $5}' | head -n 1)"

about() {
	echo "example about"
}

up() {
	package_manager_install firewalld

	sudo firewall-cmd --permanent --new-zone=hose || :
	firewall_reload

	sudo firewall-cmd --zone=hose --permanent --set-target=${config_firewall_target}

	if [[ "${config_firewall_icmp_block_inversion}" == "yes" ]]
	then sudo firewall-cmd --zone=hose --permanent --add-icmp-block-inversion
	else sudo firewall-cmd --zone=hose --permanent --remove-icmp-block-inversion
	fi

	for icmptype in $(sudo firewall-cmd --zone=hose --list-icmp-blocks); do
		sudo firewall-cmd --zone=hose --permanent --remove-icmp-block=${icmptype}
	done

	for icmptype in ${config_firewall_icmp_blocks}; do
		sudo firewall-cmd --zone=hose --permanent --add-icmp-block=${icmptype}
	done

	firewall_add_service dhcpv6-client
	firewall_add_service ssh
	sudo firewall-cmd --zone=hose --permanent --add-forward
	sudo firewall-cmd --zone=hose --permanent --change-interface="${iface}"
	firewall_reload
	sudo firewall-cmd --set-default-zone=hose
}

down() {
	sudo firewall-cmd --zone=public --permanent --change-interface="${iface}"
	firewall_reload
	sudo firewall-cmd --set-default-zone=public
}

status() {
	check_systemctl_status "firewalld" "active:enabled"

	status="$(sudo firewall-cmd --state || :)"
	check "firewall running" "running"

	check_file_exists "/etc/firewalld/zones/hose.xml"

	status="$(sudo firewall-cmd --zone=hose --list-all || :)"
	check "firewall configuration" "$(replace_placeholder "firewall-cmd--list-all" \
		iface \
		config_firewall_target \
		config_firewall_icmp_block_inversion \
		config_firewall_icmp_blocks
	)"
}
