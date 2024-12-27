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
  depends_on = [ libvirt_cloudinit_disk.commoninit ]
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
    wait_for_lease = true
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

  depends_on = [ libvirt_volume.ubuntucloud2404-img ]
}

# work around for slow boot kvm vms getting ups
resource "time_sleep" "ubuntu_wait_x_seconds" {
  depends_on = [ libvirt_domain.ubuntucloud2404  ]
  create_duration = "5s"
}

output "ip_ubuntucloud2404" {
  value = libvirt_domain.ubuntucloud2404.network_interface[0].addresses[0]
  depends_on = [ time_sleep.ubuntu_wait_x_seconds ]
}

