# get user data info
data "template_file" "user_data" {
  vars = {
    username           = data.vault_generic_secret.secret.data["kvmusername"]
    userpass           = data.vault_generic_secret.secret.data["kvmuserpass"]
    ssh_public_key     = data.vault_generic_secret.secret.data["kvmsshpublickey"]
    rootchgme          = data.vault_generic_secret.secret.data["kvmrootpass"]
  }

  template = "${file("${path.module}/cloud_init.cfg")}"

  depends_on = [ data.vault_generic_secret.secret ]
}

# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  pool = "default" # List storage pools using virsh pool-list
  user_data = "${data.template_file.user_data.rendered}"
  depends_on = [ data.vault_generic_secret.secret ]
}

# Pull private key from vault - save to local key file
resource "local_file" "ansible_labsshprivate_key" {
  filename = "labsshprivate.key"
  content  = "${data.vault_generic_secret.secret.data["kvmsshprivatekey"]}"
  file_permission = "0400"
  depends_on = [ data.vault_generic_secret.secret ]
}