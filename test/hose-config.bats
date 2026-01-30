setup() {
	load 'test-helper.bash'
	common_setup
}

write_hose_config() {
	local ssh_pub_key="${1:-"/home/testuser/.ssh/test.pub"}"
	write_config <<EOF
[hose]
user             = testuser
host             = 123.456.78.90
ssh_pub_key      = ${ssh_pub_key}
remote_path      = /home/testuser/hose
timezone         = Europe/Berlin
container_subnet = 10.11.12.0/24
plugins          = plugin-3 \\
                   plugin-2 \\
                   plugin-1
EOF
}

print_plugin_selected()  { printf "[✓] %s\n" "$1"; }
print_plugin_invalid()   { printf "[x] %s\n" "$1"; }
print_plugin_available() { printf "[-] %s\n" "$1"; }

################################################################################
# general
################################################################################

@test "prints test config" {
	run hose config
	assert_success
	assert_output "test_key = test value"
}

@test "fails when config file does not exist" {
	export HOSE_CONFIG="unknown.conf"
	run --separate-stderr hose config
	assert_fatal "${PROGRAM}: Config file not found: ${PWD}/unknown.conf"
}

@test "prints all keys and sections" {
	write_config <<EOF
key     = value

[section 1]
key1    = value 1
key2    = value 2

[section 2]
key1    = value 1
key2    = value 2
EOF

	run hose config
	assert_success
	cat <<EOF | assert_output -
key = value
[section 1]
key1 = value 1
key2 = value 2
[section 2]
key1 = value 1
key2 = value 2
EOF
}

@test "prints config section" {
	write_config <<EOF
[generic]
key1 = value 1
key2 = value 2
key3 = value 3
EOF

	run hose config generic
	assert_success
	cat <<EOF | assert_output -
key1 = value 1
key2 = value 2
key3 = value 3
EOF
}

@test "sets kv" {
	write_config <<EOF
[generic]
key1 = value 1
key2 = value 2
key3 = value 3
EOF

	for i in {1..3}; do
		run hose env --config generic "config_generic_key${i}"
		assert_success
		assert_output "declare -- config_generic_key${i}=\"value ${i}\""
	done
}

################################################################################
# [hose] config section
################################################################################

@test "prints hose config section" {
	write_hose_config
	run hose config hose
	assert_success
	cat <<EOF | assert_output -
user = testuser
host = 123.456.78.90
ssh_pub_key = /home/testuser/.ssh/test.pub
remote_path = /home/testuser/hose
timezone = Europe/Berlin
container_subnet = 10.11.12.0/24
plugins = plugin-3 plugin-2 plugin-1
EOF
}

@test "sets config_hose_user" {
	write_hose_config
	run hose env --config hose config_hose_user
	assert_success
	assert_output "declare -- config_hose_user=\"testuser\""
}

@test "sets config_hose_host" {
	write_hose_config
	run hose env --config hose config_hose_host
	assert_success
	assert_output "declare -- config_hose_host=\"123.456.78.90\""
}

@test "sets config_hose_ssh_pub_key" {
	write_hose_config
	run hose env --config hose config_hose_ssh_pub_key
	assert_success
	assert_output "declare -- config_hose_ssh_pub_key=\"/home/testuser/.ssh/test.pub\""
}

@test "sets config_hose_ssh_pub_key and replaces ~ with \$HOME" {
	# shellcheck disable=SC2088
	write_hose_config '~/.ssh/test.pub'
	run hose env --config hose config_hose_ssh_pub_key
	assert_success
	assert_output "declare -- config_hose_ssh_pub_key=\"${HOME}/.ssh/test.pub\""
}

@test "sets config_hose_ssh_pub_key and replaces \$HOME with \$HOME" {
	# shellcheck disable=SC2016
	write_hose_config '$HOME/.ssh/test.pub'
	run hose env --config hose config_hose_ssh_pub_key
	assert_success
	assert_output "declare -- config_hose_ssh_pub_key=\"${HOME}/.ssh/test.pub\""
}

@test "sets config_hose_ssh_pub_key and replaces \${HOME} with \$HOME" {
	# shellcheck disable=SC2016
	write_hose_config '${HOME}/.ssh/test.pub'
	run hose env --config hose config_hose_ssh_pub_key
	assert_success
	assert_output "declare -- config_hose_ssh_pub_key=\"${HOME}/.ssh/test.pub\""
}

@test "sets config_hose_remote_path" {
	write_hose_config
	run hose env --config hose config_hose_remote_path
	assert_success
	assert_output "declare -- config_hose_remote_path=\"/home/testuser/hose\""
}

@test "sets config_hose_timezone" {
	write_hose_config
	run hose env --config hose config_hose_timezone
	assert_success
	assert_output "declare -- config_hose_timezone=\"Europe/Berlin\""
}

@test "sets config_hose_container_subnet" {
	write_hose_config
	run hose env --config hose config_hose_container_subnet
	assert_success
	assert_output "declare -- config_hose_container_subnet=\"10.11.12.0/24\""
}

@test "sets config_hose_plugins" {
	write_hose_config
	run hose env --config hose config_hose_plugins
	assert_success
	assert_output "declare -- config_hose_plugins=\"plugin-3 plugin-2 plugin-1\""
}

################################################################################
# plugins
################################################################################

@test "prints plugins" {
	write_hose_config
	run hose plugins
	assert_success
	cat <<EOF | assert_output -
$(print_plugin_selected "plugin-3")
$(print_plugin_selected "plugin-2")
$(print_plugin_selected "plugin-1")
$(print_plugin_available "plugin-no-op")
EOF
}

@test "prints invalid plugins" {
	write_config <<EOF
[hose]
plugins = plugin-3 \
          plugin-2 \
          unknown \
          plugin-1
EOF

	run hose plugins
	assert_success
	cat <<EOF | assert_output -
$(print_plugin_selected "plugin-3")
$(print_plugin_selected "plugin-2")
$(print_plugin_invalid "unknown")
$(print_plugin_selected "plugin-1")
$(print_plugin_available "plugin-no-op")
EOF
}

@test "prints available plugins" {
	write_config <<EOF
[hose]
plugins = plugin-3 \
          plugin-1
EOF

	run hose plugins
	assert_success
	cat <<EOF | assert_output -
$(print_plugin_selected "plugin-3")
$(print_plugin_selected "plugin-1")
$(print_plugin_available "plugin-2")
$(print_plugin_available "plugin-no-op")
EOF
}
