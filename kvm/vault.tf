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

 # example populate a value
 resource "vault_generic_secret" "secret" {
  path      = "${vault_mount.kvLab.path}/config"
  data_json = jsonencode(
    {
      kvmusername = "kvmadam"
      kvmrootpass = file("ENV.labpass")
      kvmsshpublickey = file("ENV.labsshpubkey")
    }
  )
}

data "vault_generic_secret" "secret" {
  path = "${vault_mount.kvLab.path}/config"
}

# TODO: above requires two applys on first setup after destroy, fix this

#output output_kvmusername {
#  value = "${data.vault_generic_secret.secret.data["kvmusername"]}"
#  sensitive = true
#}
