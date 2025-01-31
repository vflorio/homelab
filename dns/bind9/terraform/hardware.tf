resource "dns_a_record_set" "workstation" {
  zone      = "intranet.vflorio.com."
  name      = "workstation"
  addresses = ["192.168.1.2"]
  ttl       = 3600
}

resource "dns_a_record_set" "server" {
  zone      = "intranet.vflorio.com."
  name      = "server"
  addresses = ["192.168.1.3"]
  ttl       = 3600
}

resource "dns_a_record_set" "mac" {
  zone      = "intranet.vflorio.com."
  name      = "mac"
  addresses = ["192.168.1.4"]
  ttl       = 3600
}

resource "dns_a_record_set" "notebook" {
  zone      = "intranet.vflorio.com."
  name      = "notebook"
  addresses = ["192.168.1.5"]
  ttl       = 3600
}

resource "dns_a_record_set" "tizen-tv" {
  zone      = "intranet.vflorio.com."
  name      = "tizen-tv"
  addresses = ["192.168.1.6"]
  ttl       = 3600
}

resource "dns_a_record_set" "iphone" {
  zone      = "intranet.vflorio.com."
  name      = "iphone"
  addresses = ["192.168.1.7"]
  ttl       = 3600
}

resource "dns_a_record_set" "android-tablet" {
  zone      = "intranet.vflorio.com."
  name      = "android-tablet"
  addresses = ["192.168.1.8"]
  ttl       = 3600
}

resource "dns_a_record_set" "android-tv" {
  zone      = "intranet.vflorio.com."
  name      = "android-tv"
  addresses = ["192.168.1.8"]
  ttl       = 3600
}
