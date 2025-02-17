# Create Ansible Inventory file of new KVM VMs
resource "local_file" "ansible_inventory_yaml" {
  filename = "inventory.yaml"
  content  = <<EOF
all:
  vars:
    ansible_user: ${data.vault_generic_secret.secret.data["kvmusername"]}
    ansible_ssh_private_key_file: labsshprivate.key
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no' # trusted lab, avoid ssh prompt for lab && when same IP instances later
kmvlabhosts_haproxy:
  hosts:
    lab-haproxy01:
      ansible_host: ${libvirt_domain.ubuntucloud2404_instance1.network_interface[0].addresses[0]}
      new_hostname: lab-haproxy01
kmvlabhosts_nginx:
  hosts:
    centosStream:
      ansible_host: ${libvirt_domain.centosStream.network_interface[0].addresses[0]}
      new_hostname: centos-instance1
    ubuntucloud2404_instance2:
      ansible_host: ${libvirt_domain.ubuntucloud2404_instance2.network_interface[0].addresses[0]}
      new_hostname: ubuntucloud2404-instance2
    debian:
      ansible_host: ${libvirt_domain.debian.network_interface[0].addresses[0]}
      new_hostname: debian-instance1
    rocky:
      ansible_host: ${libvirt_domain.rockyCloud.network_interface[0].addresses[0]}
      new_hostname: rocky-instance1
EOF
  
  # Ensure all VMs have finished provisioning 
  depends_on = [
    time_sleep.ubuntu_wait_x_seconds,
    time_sleep.debian_wait_x_seconds,
    time_sleep.centos_wait_x_seconds,
    time_sleep.rocky_wait_x_seconds
    ]
}

# work around for slow boot kvm vms getting ups
# ansible stage intermitent fail 
# todo: change this to ssh check available 
resource "time_sleep" "before_ansible_wait_x_seconds" {
  depends_on = [local_file.ansible_inventory_yaml]
  create_duration = "5s"
}

# Run playbook 
resource "null_resource" "output_to_terraform_ansible_log" {

  provisioner "local-exec" {
    command = "echo '# ansible-inventory' > terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible-inventory -i inventory.yaml --list >> terraform_ansible.log"
  }

  provisioner "local-exec" {
    command = "echo '# ansible ping' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible all -m ping -i inventory.yaml >> terraform_ansible.log"
  }

  provisioner "local-exec" {
    command = "echo '# ansible-playbook -i inventory.yaml playbook_base_setup.yaml' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.yaml playbook_base_setup.yaml >> terraform_ansible.log"
  }

  provisioner "local-exec" {
    command = "echo '# ansible-playbook -i inventory.yaml playbook_nginx.yaml' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.yaml playbook_nginx.yaml >> terraform_ansible.log"
  }

  provisioner "local-exec" {
    command = "echo '# ansible-playbook -i inventory.yaml playbook_haproxy_inc_ssl_and_iptables.yaml' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.yaml playbook_haproxy_inc_ssl_and_iptables.yaml >> terraform_ansible.log"
  }

  provisioner "local-exec" {
    command = "cat terraform_ansible.log"
  }

  depends_on = [time_sleep.before_ansible_wait_x_seconds]
}  
