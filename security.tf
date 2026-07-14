resource "yandex_vpc_security_group" "main_sg" {
  name       = "main-security-group"
  network_id = data.yandex_vpc_network.main.id

  # Разрешаем весь исходящий трафик (для скачивания пакетов и обновлений)
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  # Разрешаем входящий SSH только изнутри сети (для доступа через Bastion)
  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from internal network via Bastion"
    v4_cidr_blocks = ["10.10.10.0/24", "10.20.10.0/24", "10.30.10.0/24"]
    port           = 22
  }

  # Разрешаем входящий SSH на сам Bastion Host из интернета
  ingress {
    protocol       = "TCP"
    description    = "Allow SSH to Bastion from anywhere"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  # Разрешаем веб-трафик (HTTP порт 80)
  ingress {
    protocol       = "TCP"
    description    = "Allow HTTP traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  # Разрешаем доступ к интерфейсу Grafana
  ingress {
    protocol       = "TCP"
    description    = "Allow Grafana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }

  # Разрешаем доступ к интерфейсу Kibana
  ingress {
    protocol       = "TCP"
    description    = "Allow Kibana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  # Разрешаем полное внутреннее взаимодействие между всеми нашими подсетями
  ingress {
    protocol       = "ANY"
    description    = "Allow internal communication"
    v4_cidr_blocks = ["10.0.0.0/8"]
    from_port      = 0
    to_port        = 65535
  }
}
