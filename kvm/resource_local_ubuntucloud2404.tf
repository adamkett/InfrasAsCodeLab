#######################################################################
# Defining local VM Volumes 
# - download ISO/IMG/qcow2 locally so don't need to keep downloading
#
resource "libvirt_volume" "ubuntucloud2404-img" {
  name = "ubuntucloud2404.img"
  pool = "default"
  #source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  source = "/storage/isos/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

#######################################################################
# local create VM
#
resource "libvirt_domain" "ubuntucloud2404" {
  name   = "ubuntucloud2404"
  memory = "2048"
  vcpu   = 2

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = "${libvirt_volume.ubuntucloud2404-img.id}"
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