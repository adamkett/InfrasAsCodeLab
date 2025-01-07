# AWS LAB 1
#
# Derived mainly from sample AWS Terraform 
# https://github.com/hashicorp-education/learn-terraform-provisioning

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

#######################################################################
variable "cidr_vpc1" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}

variable "cidr_subnet1" {
  description = "CIDR block for subnet 1"
  default     = "10.1.1.0/24"
}

variable "cidr_subnet2" {
  description = "CIDR block for subnet 2"
  default     = "10.1.2.0/24"
}

# Virtual Private Cloud 
resource "aws_vpc" "aws_vpc_lab1" {
  cidr_block = var.cidr_vpc1
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "labaws1"
    Environment = "Environment-labaws1"
    Terraform   = "true"
  }
}

# VPC subnet 1
resource "aws_subnet" "aws_vpc_lab1_subnet1" {
  vpc_id            = aws_vpc.aws_vpc_lab1.id
  cidr_block        = var.cidr_subnet1
  availability_zone = data.vault_generic_secret.secret.data["awsavailabilityzone"]

  tags = {
    Name = "labaws1-subnet1"
  }
}

# VPC subnet 2
resource "aws_subnet" "aws_vpc_lab1_subnet2" {
  vpc_id            = aws_vpc.aws_vpc_lab1.id
  cidr_block        = var.cidr_subnet2
  availability_zone = data.vault_generic_secret.secret.data["awsavailabilityzone"]

  tags = {
    Name = "labaws1-subnet2"
  }
}

# Internet Gateway & Routing for VPC
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.aws_vpc_lab1.id
}

resource "aws_route_table" "rtb_public1" {
  vpc_id = aws_vpc.aws_vpc_lab1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.aws_vpc_lab1_subnet1.id
  route_table_id = aws_route_table.rtb_public1.id
}

#######################################################################
# Setup Security Group for this Lab
resource "aws_security_group" "sg_labaws1_allowednetworktraffic" {
  name   = "sg_labaws1_allowednetworktraffic"
  vpc_id = aws_vpc.aws_vpc_lab1.id
  description = "Allow incoming Port 22 and 80 from known hosts and all outbound traffic"

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = tolist(split(",", data.vault_generic_secret.secret.data["awsIPs_AllowedAccess_SSH"] ))
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = tolist(split(",", data.vault_generic_secret.secret.data["awsIPs_AllowedAccess_SSH"] ))
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = tolist(split(",", data.vault_generic_secret.secret.data["awsIPs_AllowedAccess_SSH"] ))
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

#######################################################################
# Cloud init - users and pass, SSH keys
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

#######################################################################
# Create EC2 instance 
resource "aws_instance" "aws_ec2_instance1" {

  # VM settings
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = var.my_aws_instance_type
  #cpu_options {
  #  core_count       = 2
  #  threads_per_core = 2
  #}

  # networking 
  subnet_id                   = aws_subnet.aws_vpc_lab1_subnet1.id
  vpc_security_group_ids      = [aws_security_group.sg_labaws1_allowednetworktraffic.id]
  associate_public_ip_address = true

  # Cloudinit
  user_data                   = "${data.template_file.user_data.rendered}"

  #monitoring = true
  #security_groups = 

  tags = {
    Name = "tf-lab1"
  }
}

output "public_ip" {
  value = aws_instance.aws_ec2_instance1.public_ip
}

output "private_ip" {
  value = aws_instance.aws_ec2_instance1.private_ip
}

#######################################################################
# Pull private key from vault - save to local key file to use by ansible 
resource "local_file" "ansible_labsshprivate_key" {
  filename = "labsshprivate.key"
  content  = "${data.vault_generic_secret.secret.data["awssshprivatekey"]}"
  file_permission = "0400"
  depends_on = [ data.vault_generic_secret.secret ]
}

#######################################################################
# Check AWS EC2 instance has come up 
resource "null_resource" "aws_ec2_instance1_check_connect" {
  provisioner "remote-exec" {
    connection {
      host = aws_instance.aws_ec2_instance1.public_dns
      user = data.vault_generic_secret.secret.data["awsusername"]
      private_key = data.vault_generic_secret.secret.data["awssshprivatekey"]
    }

    inline = ["echo 'connected!'"]
  }
  depends_on = [
    local_file.ansible_labsshprivate_key,
    aws_instance.aws_ec2_instance1
    ]
}

#######################################################################
# Create Ansible Inventory file of new EC2 instances 
resource "local_file" "ansible_inventory_yaml" {
  filename = "inventory.yaml"
  content  = <<EOF
awslabhosts:
  hosts:
    amazonlinux1:
      ansible_host: ${aws_instance.aws_ec2_instance1.public_ip}
  vars:
      ansible_user: ${data.vault_generic_secret.secret.data["awsusername"]}
      ansible_ssh_private_key_file: labsshprivate.key
      ansible_ssh_common_args: '-o StrictHostKeyChecking=no' # trusted lab, avoid ssh prompt for lab && when same IP instances later
      ansible_python_interpreter: auto_silent # amazon linux /usr/bin/python3
EOF
  depends_on = [
    null_resource.aws_ec2_instance1_check_connect
    ]
}

#######################################################################
# Run Ansible Playbook
resource "null_resource" "output_to_terraform_ansible_log" {
  
  # Ansible health check connection and gather facts 
  provisioner "local-exec" {
    command = "echo '# ansible-inventory' > terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible-inventory -i ${path.module}/inventory.ini --list >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "echo '# ansible ping' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible awslabhosts -m ping -i ${path.module}/inventory.ini >> terraform_ansible.log"
  }

  # Run Playbook 
  provisioner "local-exec" {
    command = "echo '# ansible-playbook -i inventory.yaml playbook.yaml' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/inventory.yaml playbook.yaml >> terraform_ansible.log"
  }
  
  # Display log on command line
  provisioner "local-exec" {
    command = "cat terraform_ansible.log"
  }

  depends_on = [
    local_file.ansible_inventory_yaml,
    aws_instance.aws_ec2_instance1
    ]
}  

# TODO: Setup HTTP site, pull from GIT 
# TODO: Setup 2nd ec2 instance, using ubuntu 
# TODO: Setup aws app load balancer 
# TODO: Sign valid SSL Certs 
