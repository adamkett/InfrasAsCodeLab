# Create Ansible Inventory file of new KVM VMs
resource "local_file" "ansible_inventory_yaml" {
  filename = "inventory.yaml"
  content  = <<EOF
all:
  vars:
    ansible_user: ${data.vault_generic_secret.secret.data["kvmusername"]}
    ansible_ssh_private_key_file: labsshprivate.key
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no' # trusted lab, avoid ssh prompt for lab && when same IP instances later
kmvlabhosts_nagios:
  hosts:
    lab-nagios01:
      ansible_host: ${libvirt_domain.lab-nagios01.network_interface[0].addresses[0]}
      new_hostname: lab-nagios01
kmvlabhosts_workers:
  hosts:
    lab-worker01:
      ansible_host: ${libvirt_domain.lab-worker01.network_interface[0].addresses[0]}
      new_hostname: lab-worker01
EOF
  
  # Ensure all VMs have finished provisioning 
  depends_on = [
    time_sleep.lab_nagios01_wait_x_seconds,
    time_sleep.lab_worker01_wait_x_seconds
    ]
}

# work around for slow boot kvm vms getting ups
# todo: change this to ssh check available 
resource "time_sleep" "before_ansible_wait_x_seconds" {
  depends_on = [local_file.ansible_inventory_yaml]
  create_duration = "5s"
}

# Run playbooks
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
    command = "echo '# ansible-playbook -i inventory.yaml 051-playbook_base_setup.yaml' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.yaml 051-playbook_base_setup.yaml >> terraform_ansible.log"
  }

  # Setup Nagios Clients
  provisioner "local-exec" {
    command = "echo '# ansible-playbook -i inventory.yaml 052-playbook_nagios_clients.yaml' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.yaml 052-playbook_nagios_clients.yaml >> terraform_ansible.log"
  }

  # Setup Nagios Server
  provisioner "local-exec" {
    command = "echo '# ansible-playbook -i inventory.yaml 053-playbook_nagios_server.yaml' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.yaml 053-playbook_nagios_server.yaml >> terraform_ansible.log"
  }

  # TODO: actual nagios checks beyond basic coms / up 

  # Setup Docker on Nagios server
  provisioner "local-exec" {
    command = "echo '# ansible-playbook -i inventory.yaml 061-playbook_docker.yaml' >> terraform_ansible.log"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.yaml 061-playbook_docker.yaml >> terraform_ansible.log"
  }

  # TODO: graylog

  # TODO: munin or other graphing 

  # TODO: smokeping 

  provisioner "local-exec" {
    command = "cat terraform_ansible.log"
  }

  depends_on = [time_sleep.before_ansible_wait_x_seconds]
}  

#######################################################################
output "url_nagios" {
  value = "http://${ libvirt_domain.lab-nagios01.network_interface[1].addresses[0] }/nagios4/"
  depends_on = [ null_resource.output_to_terraform_ansible_log ]
}