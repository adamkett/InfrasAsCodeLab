# Infrastructure as Code (IaC) lab

Some quick sample files used for terraform & ansible from my home lab.

More being added as and when find some time.

## Examples

Terraform/Ansible examples arranged under folders

- [vault/](vault/) - Setup vault secrets required for other examples
- [kvm/](kvm/) - terraform setup VMs via KVM with Ansible
- [docker/](docker/)
- [aws/](aws/)

Noting lab assumes vault has been 'terraform apply' first to populate values needed for other examples.

## Assumptions

My lab setup

- optimus
  - RHEL9.5 server (CIS lvl2 profile from install)
  - terraform
  - vault
  - ansible
  - kvm
  - podman
- mycroft
  - Ubuntu 24.04 LTS server
  - docker
  - kvm
- git / github / ssh access setup at user lab user
- terraform & vault setup via Hashicorp guides
- Trying to run everything with least privileges as possible.
- visual code with remote ssh folder & syntax checking.

## TODOs
Lab code
- VAULT
  - [X] Setup Lab Vault and use for terraform secrets
- KVM
  - [X] KVM - basic VMs setup
  - [X] ansible setup on new VMs created by KVM
  - [ ] nginx site & web site code from git on vms
  - [ ] load balancer across VMs website
  - [ ] Created zoned network example with kvm vms basic
   [ ] Monitoring basic
- Docker
  - [X] DOCKER examples basic
- AWS
  - [X] AWS - basic examples
  - [ ] APP LB & WAF to EC2 instances
- Cloudflare
  - [ ] Cloudflare examples basic
  - [ ] WAF/LB to EC2 instances
- Azure
  - [ ] Azure examples basic
- Windows 
  - [ ] Window Server 2022 Hyper-V examples basic
- Maybe
  - [ ] VMWARE  examples basic