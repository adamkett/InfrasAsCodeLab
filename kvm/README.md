
# terraform - kvm

## Lab setup
- optimus : RHEL 9.5 / terraform / vault / kvm
- mycroft : Ubuntu LTS as 24.04 / kvm
- network, same lan/subnet
- virtlib pool called 'isos' /storage/isos/

## Terraform / Ansible code to setup 
Create KVM Virtual machines on optimus
- [X] ubuntu
- [X] debian
- [X] centos stream
- [X] rocky

Each with
- [X] user & ssh key using cloudinit & vault variables
- [X] ansible connected and tested
- [ ] setup nginx
- [ ] nginx site pull from git
- [ ] auto update apt

Across all
- [ ] haproxy load balance
- [ ] monitoring

Create KVM Virtual machines on mycroft
- [ ] Mycroft KVM create VMs via SSH

## Notes
Other notes
[NOTES.md](NOTES.md)
