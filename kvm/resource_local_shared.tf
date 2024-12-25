# get user data info
data "template_file" "user_data" {
  vars = {
    username           = data.vault_generic_secret.secret.data["kvmusername"]
    ssh_public_key     = data.vault_generic_secret.secret.data["kvmsshpublickey"]
    rootchgme          = data.vault_generic_secret.secret.data["kvmrootpass"]
  }

  template = "${file("${path.module}/cloud_init.cfg")}"
}

# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  pool = "default" # List storage pools using virsh pool-list
  user_data = "${data.template_file.user_data.rendered}"
}