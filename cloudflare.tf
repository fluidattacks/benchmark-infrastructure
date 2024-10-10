# cloudflare.tf

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_record" "cname_records" {
  count   = length(var.subdomains)
  zone_id = var.cloudflare_zone_id
  name    = "${var.subdomains[count.index]}.${var.domain_root}" # Use domain_root variable
  type    = "CNAME"
  content = aws_instance.benchmark.public_dns # EC2 public DNS as the target
  ttl     = 0
}

variable "subdomains" {
  default = [
    "juiceshop",
    "webgoat",
    "webwolf",
    "dvws-node",
    "crapi"
  ]
}
