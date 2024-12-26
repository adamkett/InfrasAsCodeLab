
# terraform - kvm

## Lab setup

- optimus
  - RHEL 9.5
  - terraform
  - vault
  - kvm
- mycroft
  - Ubuntu LTS as 24.04
  - kvm
  - terraform access for user adam using ssh keys
  - usermod -aG kvm,libvirt,qemu adam
- network, same lan/subnet
- virtlib pool called 'isos' /storage/isos/

## notes

Using libvirt
- https://github.com/dmacvicar/terraform-provider-libvirt
- https://github.com/dmacvicar/terraform-provider-libvirt/blob/main/examples/v0.13/multiple/main.tf
- https://registry.terraform.io/providers/multani/libvirt/latest/docs/resources/volume

Based from tutorial
- https://computingforgeeks.com/how-to-provision-vms-on-kvm-with-terraform/

libvirt URIs
- https://libvirt.org/uri.html#qemu-qemu-and-kvm-uris
- keypoint = driver[+transport]://[username@][hostname][:port]/[path][?extraparameters]
- but noted "qemu+unix" on RHEL9.5 should be "qemu" for terraform provider libvirt?

Before starting can see no vms running with same name/details of what trying to create 

User session
> \[adam@optimus kvm\]\$ virsh -c qemu+unix:///session list --all \
> \[adam@optimus kvm\]\$ virsh -c qemu:///session list --all \
> \[adam@optimus kvm\]$ virsh list --all\
>  Id   Name                   State\
> \------------------------------ \
> \-    SecurityOnion          shut off\
> \-    Windows11              shut off\
> \-    WindowsServer2022VM1   shut off

System
> \[adam@optimus kvm\]\$ virsh -c qemu+unix:///system?socket=/var/run/libvirt/virtqemud-sock list --all \
> \[adam@optimus kvm\]\$ virsh -c qemu:///system?socket=/var/run/libvirt/virtqemud-sock list --all \
> \[adam@optimus kvm\]\$ virsh -c qemu:///system list --all \
> \[adam@optimus kvm\]\$ sudo virsh list --all \
> Id   Name        State \
> \------------------------------ \
> \-    opnSense1   shut off

after 

> terraform plan \
> terraform apply 

Can see leased ips in cockpit or 
> sudo virsh net-dhcp-leases default 

Clean up
> terraform destroy

added cloud config 

# ubuntu cloud 

> [adam@optimus kvm]$ sudo virsh net-dhcp-leases default

Find the ip for the vm

>[adam@optimus kvm]$ ssh -i ~/.ssh/id_ed25519_kvmadam kvmadam@192.168.122.81 

Logs in ok

>Welcome to Ubuntu 24.04.1 LTS (GNU/Linux 6.8.0-49-generic x86_64)
>
--snip--
> kvmadam@ubuntu:~$

# ansible notes

Set up optimus as control node
[adam@optimus ~]$ sudo dnf install vim-ansible.noarch ansible.noarch

TODO: KVM manage new vms
-- https://docs.ansible.com/ansible/latest/getting_started/get_started_inventory.html
-- get output from terraform for IP of new created VM
-- apply some configuration to new created KVM VMs
-- once all working merge git branch to main and push 
-- maybe need some terraform logic to pick IPs 


## TODOs
[X] Optimus KVM create VM with terraform \
[X] added ubuntu / centos stream vms \
[X] centos7 +x cloud config \
[X] cloud config to use vault secrets \
[X] Change VM to UBUNTU + Cloud/kickstart Config \
[X] Second VM to RHEL/or clone + Cloud/kickstart Config \
[ ] Fix terraform destroy and 2x apply for vault \
[X] close down centos old \
[ ] Mycroft KVM create VM \
[ ] Mycroft KVM create Network separate \
[ ] Ansible config on VM - dependent on Ansible server in place \
[ ] Root / User credentials via Hashicorp Vault
