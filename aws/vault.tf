# Ensure run vault setup first to populate values 
provider vault {
  address = "https://127.0.0.1:8200"
  
  skip_tls_verify = true  # do not do this in production
                          # TODO: Change Cert to signed and trusted by lab server 
}

data "vault_generic_secret" "secret" {
  path = "lab/aws"
}