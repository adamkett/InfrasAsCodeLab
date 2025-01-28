# Cloud init, main
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

# Cloud init, network
data "template_file" "network_data" {
  vars = {
  }
  template = "${file("${path.module}/cloud_init_network.cfg")}"
  depends_on = [ data.vault_generic_secret.secret ]
}

# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  pool = "default" # List storage pools using virsh pool-list
  user_data = "${data.template_file.user_data.rendered}"
  network_config = "${data.template_file.network_data.rendered}"
  depends_on = [ data.template_file.user_data, data.template_file.network_data ]
}

# Pull private key from vault - save to local key file
# TODO: Replace this with a Vault Value so not saved on disk, had been kept for lab convenience
resource "local_file" "ansible_labsshprivate_key" {
  filename = "labsshprivate.key"
  content  = "${data.vault_generic_secret.secret.data["kvmsshprivatekey"]}"
  file_permission = "0400"
  depends_on = [ data.vault_generic_secret.secret ]
}

#######################################################################
# Common installer VM Volume
# - download ISO/IMG/qcow1 locally so don't need to keep downloading
#
resource "libvirt_volume" "ubuntucloud2404-img" {
  name = "ubuntucloud2404.img"
  pool = "default"
  #source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  source = "/storage/isos/noble-server-cloudimg-amd64.img"
  depends_on = [ libvirt_cloudinit_disk.commoninit ]
}