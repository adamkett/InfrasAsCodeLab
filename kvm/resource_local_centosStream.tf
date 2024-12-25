#######################################################################
# Defining local VM Volumes 
# - download ISO/IMG/qcow2 locally so don't need to keep downloading
#
resource "libvirt_volume" "centosStream-qcow2" {
  name = "centosStream.qcow2"
  pool = "default"
  #source =  https://cloud.centos.org/centos/10-stream/x86_64/images/CentOS-Stream-GenericCloud-x86_64-10-latest.x86_64.qcow2
  source = "/storage/isos/CentOS-Stream-GenericCloud-x86_64-10-latest.x86_64.qcow2"
  format = "qcow2"
}

#######################################################################
# local create VM
#
resource "libvirt_domain" "centosStream" {
  name   = "centosStream"
  memory = "2048"
  vcpu   = 2

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = "${libvirt_volume.centosStream-qcow2.id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "vnc"
    listen_type = "address"
    autoport = true
  }
}