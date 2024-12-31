# terraform - docker

## Lab setup

- optimus
  - RHEL 9.5
  - terraform
- mycroft
  - Ubuntu LTS as 24.04
  - running docker
  - terraform access for user adam using ssh keys
  - usermod -aG kvm,libvirt,qemu adam
- network, same lan/subnet

## TODOs

[x] Terraform connect to mycroft\
[x] Terraform create multiple docker instances\
[ ] HA Proxy 443 with Cert to 8001/8002\
[ ] nginx docker both mount content /storage/www-content\
[ ] HA & nginx logs send somewhere useful\

## Notes
Other notes
[NOTES](NOTES)

