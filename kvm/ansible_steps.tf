# Create Ansible Inventory file of new KVM VMs
resource "local_file" "ansible_inventory_yaml" {
  filename = "inventory.yaml"
  content  = <<EOF
kmvlabhosts:
  hosts:
    centosStream:
      ansible_host: ${libvirt_domain.centosStream.network_interface[0].addresses[0]}
      ansible_user: ${data.vault_generic_secret.secret.data["kvmusername"]}
      ansible_ssh_private_key_file: labsshprivate.key
    ubuntucloud2404:
      ansible_host: ${libvirt_domain.ubuntucloud2404.network_interface[0].addresses[0]}
      ansible_user: ${data.vault_generic_secret.secret.data["kvmusername"]}
      ansible_ssh_private_key_file: labsshprivate.key
    debian:
      ansible_host: ${libvirt_domain.debian.network_interface[0].addresses[0]}
      ansible_user: ${data.vault_generic_secret.secret.data["kvmusername"]}
      ansible_ssh_private_key_file: labsshprivate.key
    rocky:
      ansible_host: ${libvirt_domain.rockyCloud.network_interface[0].addresses[0]}
      ansible_user: ${data.vault_generic_secret.secret.data["kvmusername"]}
      ansible_ssh_private_key_file: labsshprivate.key
EOF
  
  # Ensure all VMs have finished provisioning 
  depends_on = [
    time_sleep.ubuntu_wait_x_seconds,
    time_sleep.debian_wait_x_seconds,
    time_sleep.centos_wait_x_seconds,
    time_sleep.rocky_wait_x_seconds
    ]
}

# Run playbook 
resource "null_resource" "output_to_terraform_ansible_log" {
  provisioner "local-exec" {
    command = "echo '# ansible-inventory' > terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible-inventory -i ${path.module}/inventory.yaml --list >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "echo '# ansible ping' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    # This is a local trusted network,
    # option should be '-o StrictHostKeyChecking=accept-new'
    # but in the lab have repeatedly reusing IPs for different VMs
    # when create/destroy VMs a lot, caused known hosts to flag and end process 
    command = "ansible kmvlabhosts -m ping -i ${path.module}/inventory.yaml --ssh-common-args='-o StrictHostKeyChecking=no' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "echo '# ansible-playbook -i inventory.yaml playbook.yaml' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/inventory.yaml playbook.yaml >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "cat terraform_ansible.log"
  }

  depends_on = [local_file.ansible_inventory_yaml]
}  