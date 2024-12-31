# Set up AWS provider, using Lab access 
provider "aws" {
  region     = data.vault_generic_secret.secret.data["awsregion"]
  access_key = data.vault_generic_secret.secret.data["awsaccesskey"]
  secret_key = data.vault_generic_secret.secret.data["awssecretkey"]
}

variable "my_aws_instance_type" {
  type = string
  default = "t2.micro"
  description = "The instance type for the new ec2 instance"

  validation {
    condition = contains(["t2.micro", "t2.nano"], var.my_aws_instance_type)
    error_message = "The instance type must be either t2.micro or t2.nano"
  }
}

# Define Virtual Private Cloud 
resource "aws_vpc" "aws_vpc_lab1" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Terraform   = "true"
    Environment = "lab1"
  }
}

# Setup VPC subnet 1
resource "aws_subnet" "aws_vpc_lab1_subnet1" {
  vpc_id            = aws_vpc.aws_vpc_lab1.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = data.vault_generic_secret.secret.data["awsavailabilityzone"]

  tags = {
    Name = "lab1-subnet1"
  }
}

resource "aws_network_interface" "nic1" {
  subnet_id   = aws_subnet.aws_vpc_lab1_subnet1.id
  private_ips = ["10.1.1.10"]

  tags = {
    Name = "primary_network_interface"
  }
}

# Look up latest AMI of Amazon Linux 
data "aws_ami" "amazonlinux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

# Cloudinit - users and pass, SSH keys
data "template_file" "user_data" {
  vars = {
    username           = data.vault_generic_secret.secret.data["awsusername"]
    userpass           = data.vault_generic_secret.secret.data["awsuserpass"]
    ssh_public_key     = data.vault_generic_secret.secret.data["awssshpublickey"]
    rootchgme          = data.vault_generic_secret.secret.data["awsrootpass"]
  }
  template = "${file("${path.module}/cloud_init.yaml")}"
  depends_on = [ data.vault_generic_secret.secret ]
}

# TODO: remote access to vpc private ips, restrict to my static ip

# Create EC2 instance 
resource "aws_instance" "aws_ec2_instance1" {
  ami = data.aws_ami.amazonlinux.id
  instance_type = var.my_aws_instance_type

  # nic attached to a subnet 
  network_interface {
    network_interface_id = aws_network_interface.nic1.id
    device_index         = 0
  }

  # Cloudinit
  user_data = "${data.template_file.user_data.rendered}"

  #cpu_options {
  #  core_count       = 2
  #  threads_per_core = 2
  #}
  #monitoring = true
  #security_groups = 

  tags = {
    Name = "tf-lab1"
  }
}