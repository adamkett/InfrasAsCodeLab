# Notes on Networking setup

VMs running nginx placed on a separate virtual network, that is accessble 
from lab KVM Server.

VM running HAProxy is multihomed 1st interface on general LAN via bridge
and 2nd on the separate Network.

Allowing from desktop to browse to HAProy VM

Network configuration initailly done via Terraform and Cloudinit
- e.g. 020-resource_local_haproxy_ubuntucloud2404.tf -> network_interface section
- cloud_init_network.cfg

Note on distro hopping network config local to vm, changes should be
applied via terraform/ansible but can access network config locally
for testing

- RHEL
  - NetworkManager e.g. nmtui or nmcli
  - see config /etc/NetworkManager/system-connections/ens2.nmconnection
- Debian
  - netplan (netplan try/apply)
  - see config /etc/netplan/49-cloud-init.yaml 