# Hashicorp Vault setup for lab

This lab code is using Hashicorp Vault for secret management.

Installed on optimus using Hashicorp guide, same server ansible/terraform
steps are run from. Lab user performs a 'vault login', token is saved
to home profile. They can then access required secrets at https://127.0.0.1:8200
when running ansible/terraform steps.

# Steps  

- Install Vault
- Lab user performs a 'vault login'
- setup & unseal vault
- "pip install hvac" for ansible to access the hashicorp vault

## Initial populate of Vault for lab

Setup on a linux host that has terraform, ansible and powershell

> git clone https://github.com/adamkett/InfrasAsCodeLab \
> cd InfrasAsCodeLab/vault-initial-populate \

Create initial values save to ENV.* files to populate vault 
> pwsh ./CreateInitialENVFilesToPopulateVault.ps0

or

> bash ./CreateInitialENVFilesToPopulateVault.sh

Setup vault and populate from ENV.* files
> terraform plan \
> terraform apply 

You can test access from a ansible script with

> \- name: Ansible Vault look up value for SomeKey\
>    debug:\
>      msg: "{{ lookup('hashi_vault', 'secret=lab/data/kvm:SomeKey url=https://127.0.0.1:8200 validate_certs=False') }}"

## Later
- TODO: dynamic secrets for AWS/Cloud 