#######################################################################
# instance 1 will be the haproxy server 
# instance 2 will be another nginx hosting content 
#
#locals {
#  something = thing
#  depends_on = [ data.vault_generic_secret.secret ]
#}

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
# local create VM resized disks
#
# https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume
# when provisioning multiple domains using the same base image, create a
# libvirt_volume for the base image and then define the domain specific
# ones as based on it. This way the image will not be modified and no
# extra disk space is going to be used for the base image.
#
resource "libvirt_volume" "ubuntucloud2404_instance1_volume" {
  name           = "ubuntucloud2404_instance1_volume"
  pool           = "default"
  base_volume_id = "${libvirt_volume.ubuntucloud2404-img.id}"
  size           = 4294967296 # 4gb in bytes
  depends_on     = [ libvirt_volume.ubuntucloud2404-img ]
}

resource "libvirt_volume" "ubuntucloud2404_instance2_volume" {
  name           = "ubuntucloud2404_instance2_volume"
  pool           = "default"
  base_volume_id = "${libvirt_volume.ubuntucloud2404-img.id}"
  size           = 10737418240 # 10gb in bytes
  depends_on     = [ libvirt_volume.ubuntucloud2404-img ]
}

#######################################################################
# Instance 1, haproxy
resource "libvirt_domain" "ubuntucloud2404_instance1" {
  name   = "ubuntucloud2404_instance1"
  memory = "3072"
  vcpu   = 4

  # network interface on vms network
  network_interface {
    network_name = "default"
    wait_for_lease = true
    hostname = "ubuntucloud2404-instance1"
  }

  # Network interface on general lan for use with HA proxy
  # 
  # On server "brctl show" can see the bridge with a new tap for that vm
  # like the other working bridged vm but that was a manual setup so may differ
  #
  # kvm host /etc/qemu-kvm/bridge.conf needs line "allow bridge0"
  # vm config /etc/netplan/50-cloud-init.yaml
  # manual virt-xml vmname --edit --network bridge=bridge0
  network_interface {
     bridge = "bridge0"

     hostname = "lab-haproxy01"

     # Give VM the same MAC address 
     # Will get ip each time and resolves to
     # lab-haproxy01.home.arpa ref SSL cert tasks
     mac = "52:54:00:7e:5a:d3"

     wait_for_lease = true
  }

  qemu_agent = true

  disk {
    volume_id = "${libvirt_volume.ubuntucloud2404_instance1_volume.id}"
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

  depends_on = [ libvirt_volume.ubuntucloud2404_instance1_volume ]
}

#######################################################################
# Instance 2, nginx www content
resource "libvirt_domain" "ubuntucloud2404_instance2" {
  name   = "ubuntucloud2404_instance2"
  memory = "3072"
  vcpu   = 4

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = "${libvirt_volume.ubuntucloud2404_instance2_volume.id}"
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

  depends_on = [ libvirt_volume.ubuntucloud2404_instance2_volume ]
}

#######################################################################
# work around for slow boot kvm vms getting ups
resource "time_sleep" "ubuntu_wait_x_seconds" {
  depends_on = [ libvirt_domain.ubuntucloud2404_instance1, libvirt_domain.ubuntucloud2404_instance2 ]
  create_duration = "5s"
}

#######################################################################
output "ip_ubuntucloud2404_instance1" {
  value = libvirt_domain.ubuntucloud2404_instance1.network_interface[0].addresses[0]
  depends_on = [ time_sleep.ubuntu_wait_x_seconds ]
}

output "ip_ubuntucloud2404_instance1_bridge" {
  value = libvirt_domain.ubuntucloud2404_instance1.network_interface[1].addresses[0]
  depends_on = [ time_sleep.ubuntu_wait_x_seconds ]
}

#######################################################################
output "ip_ubuntucloud2404_instance2" {
  value = libvirt_domain.ubuntucloud2404_instance2.network_interface[0].addresses[0]
  depends_on = [ time_sleep.ubuntu_wait_x_seconds ]
}
