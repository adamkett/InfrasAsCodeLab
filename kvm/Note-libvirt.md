# Notes on lab libvirt setup

TODO: Tidy these notes 

Optimus 
  - Lab server running KVM running RHEL

Mycroft 
  - second server running ubuntu + kvm 
  - terraform access for lab user using ssh keys
  - usermod -aG kvm,libvirt,qemu adam

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

Can see leased ips in RHEL lab server's cockpit or 
> sudo virsh net-dhcp-leases default 

They are also present in the inventory file 

so you can login to the new vms 

>[adam@optimus kvm]$ ssh defaultlabuser@192.168.122.81 -i labsshprivate.key

>Welcome to Ubuntu 24.04.1 LTS (GNU/Linux 6.8.0-49-generic x86_64)\
> --snip-- \
> defaultlabuser@ubuntu1:~$

Clean up
> terraform destroy

# ansible notes

Set up optimus as control node
[adam@optimus ~]$ sudo dnf install vim-ansible.noarch ansible.noarch
