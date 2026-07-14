# Подключаемся к твоей существующей сети default
data "yandex_vpc_network" "main" {
  network_id = "enphn5vj51stva4dr9a4"
}

# Публичная подсеть (для Grafana, Kibana, Bastion, Балансера)
resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet-diplom"
  zone           = "ru-central1-a"
  network_id     = data.yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.110.10.0/24"]
}

# NAT-шлюз для выхода приватных серверов в интернет за пакетами
resource "yandex_vpc_gateway" "nat_gw" {
  name = "nat-gateway-diplom"
  shared_egress_gateway {}
}

# Таблица маршрутизации для NAT
resource "yandex_vpc_route_table" "private_rt" {
  name       = "private-route-table-diplom"
  network_id = data.yandex_vpc_network.main.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gw.id
  }
}

# Приватная подсеть А (для Web-сервера 1, Prometheus, Elasticsearch)
resource "yandex_vpc_subnet" "private_a" {
  name           = "private-subnet-a-diplom"
  zone           = "ru-central1-a"
  network_id     = data.yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.120.10.0/24"]
  route_table_id = yandex_vpc_route_table.private_rt.id
}

# Приватная подсеть B (для Web-сервера 2 в зоне b)
resource "yandex_vpc_subnet" "private_b" {
  name           = "private-subnet-b-diplom"
  zone           = "ru-central1-b"
  network_id     = data.yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.130.10.0/24"]
  route_table_id = yandex_vpc_route_table.private_rt.id
}
