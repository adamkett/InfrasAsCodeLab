# Infrastructure as Code (IaC) lab

Some quick sample files used for terraform & ansible from my home lab.

More being added as and when find some time.


## Examples

Terraform/Ansible examples arranged under folders

- [vault/](vault/) - Setup vault secrets required for other examples
- [aws/](aws/) - Create EC2 instance with Ansible configured in a new VPC
- [kvm/](kvm/) - terraform setup VMs via KVM with Ansible
- [docker/](docker/)

lab examples assumes vault has been populated

## Setup on a linux host that has terraform, ansible and powershell

> git clone https://github.com/adamkett/InfrasAsCodeLab \
> cd InfrasAsCodeLab/vault \

Create initial values save to ENV.* files to populate vault 
> pwsh ./CreateInitialENVFilesToPopulateVault.ps1

or

> bash ./CreateInitialENVFilesToPopulateVault.sh

Setup vault and populate from ENV.* files
> terraform plan \
> terraform apply 


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
  - [ ] Monitoring basic
  - [ ] Investigate https://ansible-lockdown.readthedocs.io/en/latest/
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
