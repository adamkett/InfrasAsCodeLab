#######################################################################
# terraform server config
#
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
    ansible = {
      source  = "ansible/ansible"
    }
  }
}

#######################################################################
# optimus - local to terraform
#
provider "libvirt" {
  # syste"
  uri = "qemu:///system?socket=/var/run/libvirt/virtqemud-sock"
}

#######################################################################
# optimus - setup vault access
#
# Note: Ensure run vault setup steps before to populate required values 
#
# Note: Vault must be unsealed & user running terraform/ansible commands
# must be logged in on the command line already.
#
# Can then access values 
#
#   output output_kvmusername {
#     value = "${data.vault_generic_secret.secret.data["kvmusername"]}"
#     sensitive = true
#   }
#
provider vault {
  address = "https://127.0.0.1:8200"
  
  skip_tls_verify = true  # do not do this in production
                          # TODO: Change Cert to signed and trusted by lab server 
}

data "vault_generic_secret" "secret" {
  path = "lab/kvm"
}

