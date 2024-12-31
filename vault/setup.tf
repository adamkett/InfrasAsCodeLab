# Initial 1 time setup of Vault value for lab
# source values from ENV* files as config
#
# ENV.awsaccesskey        needed
# ENV.awssecretkey        needed
# ENV.awsregion           optional
# ENV.awsavailabilityzone optional
# ENV.labuser             optional 
# ENV.labpass             optional 
# ENV.labsshpubkey        needed
# ENV.labsshprivatekey    needed
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

resource "random_password" "password_root" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "password_user" {
  length           = 16
  special          = true
}

# initial populate vault from files for lab from local ENV.* files 
resource "vault_generic_secret" "secretsforkvm" {
  path      = "${vault_mount.kvLab.path}/kvm"
  data_json = jsonencode(
    {
      kvmusername = fileexists("ENV.labuser") ? file("ENV.labuser") : "defaultlabuser"
      kvmuserpass = fileexists("ENV.labuserpass") ? file("ENV.labuseruser") : random_password.password_root.result
      kvmrootpass= fileexists("ENV.labpass") ? file("ENV.labpass") : random_password.password_user.result
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
      awsaccesskey = file("ENV.awsaccesskey")
      awssecretkey = file("ENV.awssecretkey")
      awsregion = fileexists("ENV.awsregion") ? file("ENV.awsregion") : "eu-west-2"
      awsavailabilityzone = fileexists("ENV.awsavailabilityzone") ? file("ENV.awsavailabilityzone") : "eu-west-2a"

      awsusername = fileexists("ENV.labuser") ? file("ENV.labuser") : "defaultlabuser"
      awsuserpass = fileexists("ENV.labuserpass") ? file("ENV.labuseruser") : random_password.password_root.result
      awsrootpass= fileexists("ENV.labpass") ? file("ENV.labpass") : random_password.password_user.result
      awssshpublickey = file("ENV.labsshpubkey")
      awssshprivatekey = file("ENV.labsshprivatekey")
    }
  )
  depends_on = [ vault_mount.kvLab ]
}