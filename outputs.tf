resource "local_file" "ansible_inventory" {
  content = <<EOT
[bastion]
bastion-host ansible_host=${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519

[web]
web-server-1 ansible_host=${yandex_compute_instance.web1.network_interface.0.ip_address} ansible_user=ubuntu
web-server-2 ansible_host=${yandex_compute_instance.web2.network_interface.0.ip_address} ansible_user=ubuntu

[monitoring]
prometheus-host ansible_host=${yandex_compute_instance.prometheus.network_interface.0.ip_address} ansible_user=ubuntu
grafana-host ansible_host=${yandex_compute_instance.grafana.network_interface.0.nat_ip_address} ansible_user=ubuntu

[logs]
elasticsearch-host ansible_host=${yandex_compute_instance.elasticsearch.network_interface.0.ip_address} ansible_user=ubuntu
kibana-host ansible_host=${yandex_compute_instance.kibana.network_interface.0.nat_ip_address} ansible_user=ubuntu
EOT
  filename = "./ansible/hosts.ini"
}
