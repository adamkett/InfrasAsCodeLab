# Initial 1 time setup of Vault value for lab
# source values from ENV* files as config
#
# ENV.awsaccesskey      needed
# ENV.awssecretkey      needed
# ENV.awsregion         needed
# ENV.labuser           optional 
# ENV.labpass           optional 
# ENV.labsshpubkey      needed
# ENV.labsshprivatekey  needed
#
# TODO: Auto generate SSH Key if none supplied 
#
provider vault {
  address = "https://127.0.0.1:8200"
  
  skip_tls_verify = true  # do not do this in production
                          # TODO: Change Cert to signed and trusted by lab server 
}

# Create the Secrets Engines "secretsKVM" type kv
resource "vault_mount" "kvLab" {
  path      = "lab"
  type      = "kv"
  options = {
    version = "2"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# initial populate vault from files for lab from local ENV.* files 
resource "vault_generic_secret" "secretsforkvm" {
  path      = "${vault_mount.kvLab.path}/kvm"
  data_json = jsonencode(
    {
      kvmusername = fileexists("ENV.labuser") ? file("ENV.labuser") : "defaultlabuser"
      kvmrootpass= fileexists("ENV.labpass") ? file("ENV.labpass") : random_password.password.result
      kvmsshpublickey = file("ENV.labsshpubkey")
      kvmsshprivatekey = file("ENV.labsshprivatekey")
    }
  )
  depends_on = [ vault_mount.kvLab ]
}

resource "vault_generic_secret" "secretsforaws" {
  path      = "${vault_mount.kvLab.path}/aws"
  data_json = jsonencode(
    {
      awsregion = file("ENV.awsregion")
      awsaccesskey = file("ENV.awsaccesskey")
      awssecretkey = file("ENV.awssecretkey")
    }
  )
  depends_on = [ vault_mount.kvLab ]
}