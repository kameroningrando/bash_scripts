#! /bin/bash

## Original source: https://gist.github.com/chriswayg/b6421dcc69cb3b7e41f2998f1150e1df

# Create VM
qm create 9000 --name debian10-cloud --memory 1024 --net0 virtio,bridge=vmbr1

# Import disk in qcow2 format
qm importdisk 9000 debian-10-generic-amd64-20210208-542.qcow2 vmdata -format qcow2

# Attach disk using VirtIO SCSI
qm set 9000 --scsihw virtio-scsi-pci --scsi0 /mnt/vmdata/images/9000/vm-9000-disk-0.qcow2

# Attach to App server bridge
qm set 9000 --net0 virtio,bridge=vmbr2

# Cloud init settings
qm set 9000 --ide2 local-lvm:cloudinit --boot c --bootdisk scsi0 --serial0 socket --vga serial0

# Resize OS drive
qm resize 9000 scsi0 +8G

# Set vmbr1 to dhcp
qm set 9000 --ipconfig0 ip=dhcp

# User authentication for 'debian' user
qm set 9000 --sshkey ~/.ssh/id_ecdsa1.pub

# Check the cloud-init config
qm cloudinit dump 9000 user

# Create template
qm template 9000