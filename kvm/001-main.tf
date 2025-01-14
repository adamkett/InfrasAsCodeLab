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
  # "system"
  uri = "qemu:///system?socket=/var/run/libvirt/virtqemud-sock"
  #
  # "session"
  # can access as session ref 
  # uri = "qemu:///session?socket=/run/user/1000/libvirt/virtqemud-sock"
  # https://github.com/dmacvicar/terraform-provider-libvirt/issues/906
  # but then run into the problem of access network needing to create
  # session one this etc & changing storage pool location + userid value
}

#######################################################################
# mycroft - terraform via ssh 
#
# mycroft kvm ssh adam/root, don't want to enable root ssh allow 
# provider "libvirt" {
#   alias = "mycroft"
#   uri   = "qemu+ssh://root@mycroft/system"
# }
#
provider "libvirt" {
  alias = "mycroft"
  uri   = "qemu+ssh://adam@mycroft/session"
}