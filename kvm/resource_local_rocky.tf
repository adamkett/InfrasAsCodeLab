#######################################################################
# Defining local VM Volumes 
# - download ISO/IMG/qcow2 locally so don't need to keep downloading
#
resource "libvirt_volume" "rockyCloud-qcow2" {
  name = "rockyCloud.qcow2"
  pool = "default"
  #source =  https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2
  source = "/storage/isos/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  format = "qcow2" 
  
  depends_on = [ libvirt_cloudinit_disk.commoninit ]
}

#######################################################################
# local create VM
#
resource "libvirt_domain" "rockyCloud" {
  name   = "rockyCloud"
  memory = "2048"
  vcpu   = 2

  cpu {
    mode = "host-passthrough"
    #mode = "host-model"
  }

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = "${libvirt_volume.rockyCloud-qcow2.id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type = "vnc"
    listen_type = "address"
    autoport = true
  }
  
  depends_on = [ libvirt_volume.rockyCloud-qcow2 ]
}

# work around for slow boot kvm vms getting ups
resource "time_sleep" "rocky_wait_x_seconds" {
  depends_on = [ libvirt_domain.rockyCloud  ]
  create_duration = "5s"
}

output "ip_rockyCloud" {
  value = libvirt_domain.rockyCloud.network_interface[0].addresses[0]
}

# sudo virsh console rockyCloud
