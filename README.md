# Infrastructure as Code (IaC) lab

Some quick sample files used for terraform & ansible from my home lab.  Will add more as & when time I have time.


## Examples

Terraform/Ansible examples arranged under folders

- [vault-inital-populate/](vault-inital-populate/)
  - Initial populate vault secrets
  - Required for other examples to work
  - helper pwsh/bash scripts
- [aws/](aws/)
  - Terraform Create
    - new VPC, subnet, IGW in specified region
    - Create EC2 instances
      - cloud init
      - allow access from known IP (aws security group)
  - Ansible configure EC2 instances
  - TODO: SSL Certs
  - TODO: AWS App LoadBalancer & DNS
  - TODO: Dynamic secret from vault
- [kvm/](kvm/)
  - Terraform setup VMs via KVM with Ansible
    - cloud init
    - RHEL based
    - Debian based
  - Ansible configure instances
    - install base software / configuration
    - 1x VMs haproxy as loadbalancer t0 nginx vms
    - 4x VMs nginx content
      - GIT pull content
      - add host ID in page
  - TODO: SSL Letsencrypt
- [docker/](docker/)
  - Terraform create basic docker instances on remote host
- TODO: Cloudflare DNS/LB/WAF/CDN
- TODO: Add monitoring
- TODO: review ansible-lockdown
- TODO: hyperv windows server 2022 (if nested virt works)
- TODO: Azure Examples

## My Lab Setup

- optimus
  - RHEL9.5 server
    - CIS lvl2 profile from install
    - Spec to support amount of VMs e.g. 64gb ram / 13th gen i5 CPU
  - terraform
    - setup via Hashicorp guides
  - vault
    - Setup as https://127.0.0.1:8200
    - Assumed
      - user running terraform/ansible has performed vault login
      - user has performed initial vault populate
  - ansible
  - kvm
    - Networks
      - Natted network access via default network
      - local LAN via bridge0
  - podman
  - ssh
    - Every so often, clear out junk entries in known hosts
- mycroft
  - Ubuntu 24.04 LTS server
  - docker
  - kvm
- git / github / ssh / vault access setup as user running lab commands
- run with least privileges as practical for lab
- using visual code with remote ssh folder & syntax checking