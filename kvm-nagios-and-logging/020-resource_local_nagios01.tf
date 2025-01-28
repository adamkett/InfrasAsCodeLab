#######################################################################
# nagios01 to run Nagios Server
#
#locals {
#  something = thing
#  depends_on = [ data.vault_generic_secret.secret ]
#}

#######################################################################
# local create VM resized disks
#
# https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume
# when provisioning multiple domains using the same base image, create a
# libvirt_volume for the base image and then define the domain specific
# ones as based on it. This way the image will not be modified and no
# extra disk space is going to be used for the base image.
#
resource "libvirt_volume" "lab_nagios01_volume" {
  name           = "lab_nagios01_volume"
  pool           = "default"
  base_volume_id = "${libvirt_volume.ubuntucloud2404-img.id}"
  size           = 21474836480 # 20gb in bytes
  depends_on     = [ libvirt_volume.ubuntucloud2404-img ]
}

#######################################################################
# Instance 1, haproxy
resource "libvirt_domain" "lab-nagios01" {
  name   = "lab-nagios01"
  memory = "3072"
  vcpu   = 4

  # Testing docker withing a VM
  cpu {
    mode = "host-passthrough"
  }

  # network interface on VMs network
  network_interface {
    network_name = "default"
    wait_for_lease = true
    hostname = "lab-nagios01-vnet"
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
     hostname = "lab-nagios01"

     # Give VM the same MAC address each rebuild to get same
     # DHCP Lease for lab-nagios01.home.arpa on main network
     mac = "52:54:00:7e:5a:d4"

     wait_for_lease = true
  }

  qemu_agent = true

  disk {
    volume_id = "${libvirt_volume.lab_nagios01_volume.id}"
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

  depends_on = [ libvirt_volume.lab_nagios01_volume ]
}

#######################################################################
# work around for slow boot kvm vms getting ups
resource "time_sleep" "lab_nagios01_wait_x_seconds" {
  depends_on = [ libvirt_domain.lab-nagios01 ]
  create_duration = "5s"
}

#######################################################################
output "ip_lab_nagios01" {
  value = libvirt_domain.lab-nagios01.network_interface[0].addresses[0]
  depends_on = [ time_sleep.lab_nagios01_wait_x_seconds ]
}

output "ip_lab_nagios01_bridge" {
  value = libvirt_domain.lab-nagios01.network_interface[1].addresses[0]
  depends_on = [ time_sleep.lab_nagios01_wait_x_seconds ]
}
