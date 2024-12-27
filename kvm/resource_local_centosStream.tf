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
  
  depends_on = [ libvirt_cloudinit_disk.commoninit ]
}

#######################################################################
# local create VM
#
resource "libvirt_domain" "centosStream" {
  name   = "centosStream"
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
    volume_id = "${libvirt_volume.centosStream-qcow2.id}"
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
  
  depends_on = [ libvirt_volume.centosStream-qcow2 ]
}

# work around for slow boot kvm vms getting ups
resource "time_sleep" "centos_wait_x_seconds" {
  depends_on = [ libvirt_domain.centosStream  ]
  create_duration = "5s"
}

output "ip_centosStream" {
  value = libvirt_domain.centosStream.network_interface[0].addresses[0]
}

# sudo virsh console centosStream
