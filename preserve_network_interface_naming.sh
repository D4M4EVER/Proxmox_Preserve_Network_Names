#!/bin/bash

# Log file path
LOG_FILE="log-preserve_network_interface_naming.txt"

# Function to print progress and log to a file
print_progress() {
    local message="$1"
    echo "$(date +"%T") - $message" | tee -a "$LOG_FILE"
}

# Function to print error and exit with a non-zero status
print_error_and_exit() {
    local error_message="$1"
    print_progress "Error: $error_message"
    exit 1
}

# Function to validate MAC address format
validate_mac_address() {
    local mac_address="$1"
    if [[ ! "$mac_address" =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]; then
        return 1
    fi
    return 0
}

# Function to filter out invalid MAC addresses
filter_mac_addresses() {
    local mac_addresses="$1"
    local filtered_mac_addresses=""
    while IFS= read -r line; do
        local interface_name=$(echo "$line" | awk '{print $1}')
        local mac_address=$(echo "$line" | awk '{print $2}')
        if validate_mac_address "$mac_address"; then
            filtered_mac_addresses="$filtered_mac_addresses $mac_address"
        else
            print_progress "Invalid MAC address found for interface $interface_name: $mac_address"
        fi
    done <<< "$mac_addresses"
    echo "$filtered_mac_addresses"
}

# Function to create systemd link files for the raw interfaces
create_systemd_link_files() {
    local interface_names="$1"
    for interface_name in $interface_names; do
        local link_file="/etc/systemd/network/10-$interface_name.link"
        local mac_address=$(ip -o link show "$interface_name" | awk '{print $(NF-2)}')
        cat << EOF > "$link_file"
[Match]
MACAddress=$mac_address

[Link]
Name=$interface_name
EOF
        print_progress "Created systemd link file for interface $interface_name: $link_file"
        print_progress "Contents of $link_file:"
        cat "$link_file" | sed 's/^/    /' # Log the contents of the created link file
    done
}

# Main function
main() {
    print_progress "Starting script..."

    # Check if running with root privileges
    if [[ $EUID -ne 0 ]]; then
        print_error_and_exit "This script must be run as root."
    fi

    # Check if /etc/network/interfaces exists
    interfaces_file="/etc/network/interfaces"
    if [[ ! -f "$interfaces_file" ]]; then
        print_error_and_exit "$interfaces_file does not exist."
    fi

    # Get the names of raw network interfaces from /etc/network/interfaces
    interface_names=$(awk '/^iface/ && !/vmbr|lo|bond|vlan/ {print $2}' "$interfaces_file")

    # Print the names of the interfaces from /etc/network/interfaces
    print_progress "Raw interfaces defined in /etc/network/interfaces:"
    echo "$interface_names"

    # Get the MAC addresses of the raw network interfaces
    print_progress "Getting MAC addresses for raw interfaces..."
    mac_addresses=$(ip -o link | awk '$2 !~ /vmbr|lo|bond|vlan/ {print $2, $(NF-2)}')
    print_progress "MAC addresses for raw interfaces found:"
    echo "$mac_addresses"

    # Filter MAC addresses based on the interfaces defined in /etc/network/interfaces
    filtered_mac_addresses=$(filter_mac_addresses "$mac_addresses")

    # Print the filtered MAC addresses
    print_progress "Filtered MAC addresses:"
    echo "$filtered_mac_addresses"

    # Create systemd link files for the raw interfaces
    create_systemd_link_files "$interface_names"

    print_progress "Script completed."
}

# Execute main function
main
