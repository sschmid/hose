firewall_add_service() {
	sudo firewall-cmd --zone=hose --permanent --add-service="$1"
}

firewall_reload() {
	sudo firewall-cmd --reload
}
