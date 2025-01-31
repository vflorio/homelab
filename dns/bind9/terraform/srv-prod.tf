# Server Prod 0

resource "dns_a_record_set" "srv_prod_0" {
  zone      = "intranet.vflorio.com."
  name      = "srv-prod-0"
  addresses = ["192.168.1.170"]
  ttl       = 3600
}

resource "dns_a_record_set" "srv_prod_0_wildcard" {
  zone      = "intranet.vflorio.com."
  name      = "*.srv-prod-0"
  addresses = ["192.168.1.170"]
  ttl       = 3600
}

# Server Prod 1

resource "dns_a_record_set" "srv_prod_1" {
  zone      = "intranet.vflorio.com."
  name      = "srv-prod-1"
  addresses = ["192.168.1.171"]
  ttl       = 3600
}

resource "dns_a_record_set" "srv_prod_1_wildcard" {
  zone      = "intranet.vflorio.com."
  name      = "*.srv-prod-1"
  addresses = ["192.168.1.171"]
  ttl       = 3600
}

# Server Prod 2

resource "dns_a_record_set" "srv_prod_2" {
  zone      = "intranet.vflorio.com."
  name      = "srv-prod-2"
  addresses = ["192.168.1.172"]
  ttl       = 3600
}

resource "dns_a_record_set" "srv_prod_2_wildcard" {
  zone      = "intranet.vflorio.com."
  name      = "*.srv-prod-2"
  addresses = ["192.168.1.172"]
  ttl       = 3600
}

# Server Prod 3

resource "dns_a_record_set" "srv_prod_3" {
  zone      = "intranet.vflorio.com."
  name      = "srv-prod-3"
  addresses = ["192.168.1.173"]
  ttl       = 3600
}

resource "dns_a_record_set" "srv_prod_3_wildcard" {
  zone      = "intranet.vflorio.com."
  name      = "*.srv-prod-3"
  addresses = ["192.168.1.173"]
  ttl       = 3600
}
