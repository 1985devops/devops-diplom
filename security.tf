# 1. ГРУППА ДЛЯ BASTION-ХОСТА (Доступ по SSH только вам)
resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["109.124.110.26/32"] # Ваш IP
    port           = 22
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. ГРУППА ДЛЯ БАЛАНСИРОВЩИКА (ALB) (Принимает HTTP со всего интернета)
resource "yandex_vpc_security_group" "alb" {
  name       = "alb-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. ГРУППА ДЛЯ WEB-СЕРВЕРОВ (Принимают трафик ТОЛЬКО от балансировщика и Bastion)
resource "yandex_vpc_security_group" "web" {
  name       = "web-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    security_group_id = yandex_vpc_security_group.alb.id # Только от ALB
    port           = 80
  }
  ingress {
    protocol       = "TCP"
    security_group_id = yandex_vpc_security_group.bastion.id # SSH от Bastion
    port           = 22
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. ГРУППА ДЛЯ МОНИТОРИНГА (Grafana/Prometheus — доступ к 3000 только вам)
resource "yandex_vpc_security_group" "monitoring" {
  name       = "monitoring-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["109.124.110.26/32"] # Доступ к Grafana только вам
    port           = 3000
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"] # Сбор метрик внутри сети
    port           = 9090
  }
  ingress {
    protocol       = "TCP"
    security_group_id = yandex_vpc_security_group.bastion.id # SSH от Bastion
    port           = 22
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. ГРУППА ДЛЯ ЛОГИРОВАНИЯ (Kibana/Elasticsearch — доступ к 5601 только вам)
resource "yandex_vpc_security_group" "logging" {
  name       = "logging-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["109.124.110.26/32"] # Доступ к Kibana только вам
    port           = 5601
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"] # Прием логов внутри сети
    port           = 9200
  }
  ingress {
    protocol       = "TCP"
    security_group_id = yandex_vpc_security_group.bastion.id # SSH от Bastion
    port           = 22
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
