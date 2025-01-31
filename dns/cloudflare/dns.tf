# Cloudflare DNS
# ---
# Templates to manage DNS Records on Cloudflare

resource "cloudflare_record" "intranet" {
    name = "intranet"
    type = "AAAA"
    zone_id = var.cloudflare_zone_id
    content =  var.public_ipv6
    proxied = true
}

resource "cloudflare_record" "gitlab" {
    name = "gitlab"
    type = "AAAA"
    zone_id = var.cloudflare_zone_id
    content =  var.public_ipv6
    proxied = true
}

resource "cloudflare_record" "nextcloud" {
    name = "nextcloud"
    type = "AAAA"
    zone_id = var.cloudflare_zone_id
    content =  var.public_ipv6
    proxied = true
}

resource "cloudflare_record" "bitwarden" {
    name = "bitwarden"
    type = "AAAA"
    zone_id = var.cloudflare_zone_id
    content =  var.public_ipv6
    proxied = true
}

resource "cloudflare_record" "emby" { 
    name = "emby"
    type = "AAAA"
    zone_id = var.cloudflare_zone_id
    content =  var.public_ipv6
    proxied = true
}

resource "cloudflare_record" "penpot" { 
    name = "penpot"
    type = "AAAA"
    zone_id = var.cloudflare_zone_id
    content =  var.public_ipv6
    proxied = true
}

resource "cloudflare_record" "onlyoffice" { 
    name = "onlyoffice"
    type = "AAAA"
    zone_id = var.cloudflare_zone_id
    content =  var.public_ipv6
    proxied = true
}