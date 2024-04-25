# Proxmox VE 8.2 & Proxmox Backup Server 3.2

# Preserve Network Interface Naming Script

This Bash script is designed to preserve the current network interface naming scheme prior to upgrading to Proxmox VE 8.2 and Proxmox Backup Server 3.2.
It prevents network interfaces from being automatically renamed from "enp1", "enp2", "enp3", etc., to "enp1p1", "enp2p2", "enp3p3", etc., preserving the previous network interface naming scheme.

## Purpose

Proxmox VE 8.2 and Proxmox Backup Server 3.2 upgraded to the lastet 6.8 kernal. 
This causes the naming scheme for network interfaces to change, which can lead to invalid network configurations after a reboot. 
This script helps users maintain consistency in their network interface naming scheme when upgrading to Proxmox VE 8.2 and Proxmox Backup Server 3.2.

## Usage

1. **Download the Script**: You can download the script using `wget` with the following command:

    ```bash
    wget -qLO preserve_network_interface_naming.sh https://github.com/D4M4EVER/Proxmox_Preserve_Network_Names/raw/main/preserve_network_interface_naming.sh
    ```


2. **Make the Script Executable**: After downloading, make the script executable using the following command:

    ```bash
    chmod +x preserve_network_interface_naming.sh
    ```


3. **Run the Script**: Execute the script with root privileges:

    ```bash
    sudo ./preserve_network_interface_naming.sh
    ```


## References

- Proxmox VE Administration Guide: [Network Override Device Names](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#network_override_device_names)

## Notes

- Ensure you have proper backups of your system before running the script, especially if you are making changes to network configurations.
- This script is designed for use with Proxmox VE environments but can be adapted for other Debian-based systems with similar network interface configurations.

## Contributing

Feel free to contribute to this script by submitting pull requests or raising issues.
