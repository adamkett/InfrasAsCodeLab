#######################################################################
# remote - create VM
#
# resource "libvirt_domain" "remotehost-domain" {
#   provider = libvirt.remotehost
#   name     = "remotehost"
#   memory   = "2048"
#   vcpu     = 2
# 
#   disk {
#     volume_id = libvirt_volume.remotehost-qcow2.id
#   }
# }
