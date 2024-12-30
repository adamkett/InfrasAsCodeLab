provider "aws" {
  region     = data.vault_generic_secret.secret.data["awsregion"]
  access_key = data.vault_generic_secret.secret.data["awsaccesskey"]
  secret_key = data.vault_generic_secret.secret.data["awssecretkey"]
}

/*
# Step 3: Use the provider to create resources
Provider "aws" {
  …
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
*/