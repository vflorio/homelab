# Server demo 0

resource "dns_a_record_set" "srv_demo_0" {
  zone      = "intranet.vflorio.com."
  name      = "srv-demo-0"
  addresses = ["192.168.1.180"]
  ttl       = 3600
}

resource "dns_a_record_set" "srv_demo_0_wildcard" {
  zone      = "intranet.vflorio.com."
  name      = "*.srv-demo-0"
  addresses = ["192.168.1.180"]
  ttl       = 3600
}

# Server demo 1

resource "dns_a_record_set" "srv_demo_1" {
  zone      = "intranet.vflorio.com."
  name      = "srv-demo-1"
  addresses = ["192.168.1.181"]
  ttl       = 3600
}

resource "dns_a_record_set" "srv_demo_1_wildcard" {
  zone      = "intranet.vflorio.com."
  name      = "*.srv-demo-1"
  addresses = ["192.168.1.181"]
  ttl       = 3600
}

# Server demo 2

resource "dns_a_record_set" "srv_demo_2" {
  zone      = "intranet.vflorio.com."
  name      = "srv-demo-2"
  addresses = ["192.168.1.182"]
  ttl       = 3600
}

resource "dns_a_record_set" "srv_demo_2_wildcard" {
  zone      = "intranet.vflorio.com."
  name      = "*.srv-demo-2"
  addresses = ["192.168.1.182"]
  ttl       = 3600
}

# Server demo 3

resource "dns_a_record_set" "srv_demo_3" {
  zone      = "intranet.vflorio.com."
  name      = "srv-demo-3"
  addresses = ["192.168.1.183"]
  ttl       = 3600
}

resource "dns_a_record_set" "srv_demo_3_wildcard" {
  zone      = "intranet.vflorio.com."
  name      = "*.srv-demo-3"
  addresses = ["192.168.1.183"]
  ttl       = 3600
}
