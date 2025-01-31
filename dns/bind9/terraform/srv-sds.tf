# prod

resource "dns_a_record_set" "sds_prod" {
  zone      = "intranet.vflorio.com."
  name      = "sds-prod"
  addresses = ["192.168.1.190"]
  ttl       = 3600
}

resource "dns_a_record_set" "sds_prod_wildcard" {
  zone      = "intranet.vflorio.com."
  name      = "*.sds-prod"
  addresses = ["192.168.1.190"]
  ttl       = 3600
}

# stage

resource "dns_a_record_set" "sds_stage" {
  zone      = "intranet.vflorio.com."
  name      = "sds-stage"
  addresses = ["192.168.1.191"]
  ttl       = 3600
}

resource "dns_a_record_set" "sds_stage_wildcard" {
  zone      = "intranet.vflorio.com."
  name      = "*.sds-stage"
  addresses = ["192.168.1.191"]
  ttl       = 3600
}

# dev

resource "dns_a_record_set" "sds_dev" {
  zone      = "intranet.vflorio.com."
  name      = "sds-dev"
  addresses = ["192.168.1.192"]
  ttl       = 3600
}

resource "dns_a_record_set" "sds_dev_wildcard" {
  zone      = "intranet.vflorio.com."
  name      = "*.sds-dev"
  addresses = ["192.168.1.192"]
  ttl       = 3600
}