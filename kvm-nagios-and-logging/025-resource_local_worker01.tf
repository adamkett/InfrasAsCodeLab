#######################################################################
# worker01 
#
# TODO: Update to be worker01-03 with count loop

#######################################################################
# local create VM resized disks
#
resource "libvirt_volume" "lab_worker01_volume" {
  name           = "lab_worker01_volume"
  pool           = "default"
  base_volume_id = "${libvirt_volume.ubuntucloud2404-img.id}"
  size           = 4294967296 # 4gb in bytes
  depends_on     = [ libvirt_volume.ubuntucloud2404-img ]
}

#######################################################################
# Instance 1, haproxy
resource "libvirt_domain" "lab-worker01" {
  name   = "lab-worker01"
  memory = "3072"
  vcpu   = 4

  # network interface on VMs network
  network_interface {
    network_name = "default"
    wait_for_lease = true
    hostname = "lab-worker01"
  }

  disk {
    volume_id = "${libvirt_volume.lab_worker01_volume.id}"
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

  depends_on = [ libvirt_volume.lab_worker01_volume ]
}

#######################################################################
# work around for slow boot kvm vms getting ups
resource "time_sleep" "lab_worker01_wait_x_seconds" {
  depends_on = [ libvirt_domain.lab-worker01 ]
  create_duration = "5s"
}

#######################################################################
output "ip_lab_worker01" {
  value = libvirt_domain.lab-worker01.network_interface[0].addresses[0]
  depends_on = [ time_sleep.lab_worker01_wait_x_seconds ]
}