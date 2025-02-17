#######################################################################
# Defining local VM Volumes 
# - download ISO/IMG/qcow2 locally so don't need to keep downloading
#
resource "libvirt_volume" "debian_img" {
  name = "debian.img"
  pool = "default"
  #source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  source = "/storage/isos/debian-12-genericcloud-amd64.qcow2"
  format = "qcow2"
  depends_on = [ libvirt_cloudinit_disk.commoninit ]
}

#######################################################################
# local create VM resized disks
#
resource "libvirt_volume" "debian_instance1_volume" {
  name           = "debian_instance1_volume"
  pool           = "default"
  base_volume_id = "${libvirt_volume.debian_img.id}"
  size           = 10737418240 # 10gb in bytes
  depends_on     = [ libvirt_volume.debian_img ]
}

resource "libvirt_domain" "debian" {
  name   = "debian"
  memory = "3072"
  vcpu   = 4

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = "${libvirt_volume.debian_instance1_volume.id}"
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

  depends_on = [ libvirt_volume.debian_instance1_volume ]
}

# work around for slow boot kvm vms getting ups
resource "time_sleep" "debian_wait_x_seconds" {
  depends_on = [ libvirt_domain.debian ]
  create_duration = "5s"
}

output "ip_debian" {
  value = libvirt_domain.debian.network_interface[0].addresses[0]
  depends_on = [ time_sleep.debian_wait_x_seconds ]
}

