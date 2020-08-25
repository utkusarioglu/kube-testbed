#!/bin/sh

echo 'Setting static IP: $MACHINE_IP address for Hyper-V...'
cd /etc/netplan/
cat << EOF > $(ls)
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses: [$MACHINE_IP4/24]
      gateway4: $GATEWAY_IP4
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
EOF

# Be sure NOT to execute "netplan apply" here, so the changes take effect on
# reboot instead of immediately, which would disconnect the provisioner.