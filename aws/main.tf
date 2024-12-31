# Set up AWS provider, using Lab access 
provider "aws" {
  region     = data.vault_generic_secret.secret.data["awsregion"]
  access_key = data.vault_generic_secret.secret.data["awsaccesskey"]
  secret_key = data.vault_generic_secret.secret.data["awssecretkey"]
}

# Setup VPC
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
data "aws_ami" "this" {
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

# Create EC2 instance 
resource "aws_instance" "aws_ec2_instance1" {
  ami = data.aws_ami.this.id
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.nic1.id
    device_index         = 0
  }
}