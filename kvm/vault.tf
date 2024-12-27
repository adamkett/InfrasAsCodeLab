provider vault {
  address = "https://127.0.0.1:8200"
}

# Create the Secrets Engines "secretsKVM" type kv
resource "vault_mount" "kvLab" {
  path      = "labkvm"
  type      = "kv"
  options = {
    version = "2"
  }
}

# initial populate vault from files for lab from local ENV.* files 
resource "vault_generic_secret" "secret" {
  path      = "${vault_mount.kvLab.path}/config"
  data_json = jsonencode(
    {
      kvmusername = file("ENV.labuser")
      kvmrootpass = file("ENV.labpass")
      kvmsshpublickey = file("ENV.labsshpubkey")
      kvmsshprivatekey = file("ENV.labsshprivatekey")
    }
  )

  depends_on = [ vault_mount.kvLab ]
}

data "vault_generic_secret" "secret" {
  path = "${vault_mount.kvLab.path}/config"
  depends_on = [ vault_generic_secret.secret ]
}

# see resource_local_shared.tf for example using vault values

#output output_kvmusername {
#  value = "${data.vault_generic_secret.secret.data["kvmusername"]}"
#  sensitive = true
#}
