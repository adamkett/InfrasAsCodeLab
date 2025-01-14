##############################################################################################################
# Domain: sitedomain.tld, hosted with cloudflare 
##############################################################################################################
#
# Cloudflare: Setup a Account token with scoped to Zone & relevant permissions 
# https://developers.cloudflare.com/fundamentals/api/get-started/create-token/
# And restricted access from IP 
#
# Vault: Secrets needed in vault - see vault setup of
#      cf_api_token, cf_account_id, cf_zone_id, cf_domain
#
# Onboarding existing domain to Terraform: if domain has been managed via dashboard, need
# to get current configuration into terraform cf-terraforming generate (create code)
# & import (update terraform state).
#
# See  
#   https://developers.cloudflare.com/terraform/advanced-topics/import-cloudflare-resources/
#   https://github.com/cloudflare/cf-terraforming/releases
#
# Need to do this for each resource type managing via terraform
# e.g cf-terraforming generate for each cloudflare_ruleset and cloudflare_ruleset
#
# TODO: fix running cf-terraforming on optimus
# 
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
      #version = "5.0.0-rc1"
    }
  }
}

provider vault {
  address = "https://127.0.0.1:8200"    # user running terraform is logged into vault
  skip_tls_verify = true                # do not do this in production
                                        # TODO: Change Cert to signed and trusted by lab server 
}

provider "cloudflare" {
  api_token = "${data.vault_generic_secret.secret.data["cf_api_token"]}"
}

data "vault_generic_secret" "secret" {
  path = "lab/cloudflare"
}

locals {
  cf_account_id = "${data.vault_generic_secret.secret.data["cf_account_id"]}"

  cf_zone_id = "${data.vault_generic_secret.secret.data["cf_zone_id"]}"
  cf_domain = "${data.vault_generic_secret.secret.data["cf_domain"]}"

  # used for redirecting page rules
  redirect_to_URL = "https://github.com/adamkett/InfrasAsCodeLab"
}

resource "cloudflare_record" "terraform_managed_resource_zoneroot" {
  content = "localhost"
  name    = local.cf_domain
  proxied = true
  ttl     = 1
  type    = "CNAME"
  zone_id = local.cf_zone_id
  comment   = "#domain_${local.cf_domain}"
}

resource "cloudflare_record" "terraform_managed_resource_www" {
  content = "localhost"
  name    = "www"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  zone_id = local.cf_zone_id
  comment   = "#domain_${local.cf_domain}"
}

# MX records = zone is managed by Email Routing.
#
#resource "cloudflare_record" "terraform_managed_resource_mx2" {
#  content  = "route3.mx.cloudflare.net"
#  name     = local.cf_domain
#  priority = 95
#  proxied  = false
#  ttl      = 1
#  type     = "MX"
#  zone_id = local.cf_zone_id
#}
#
#resource "cloudflare_record" "terraform_managed_resource_mx1" {
#  content  = "route2.mx.cloudflare.net"
#  name     = local.cf_domain
#  priority = 5
#  proxied  = false
#  ttl      = 1
#  type     = "MX"
#  zone_id = local.cf_zone_id
#}
#
#resource "cloudflare_record" "terraform_managed_resource_mx3" {
#  content  = "route1.mx.cloudflare.net"
#  name     = local.cf_domain
#  priority = 49
#  proxied  = false
#  ttl      = 1
#  type     = "MX"
#  zone_id = local.cf_zone_id
#}

resource "cloudflare_record" "terraform_managed_resource_spf" {
  content = "\"v=spf1 include:_spf.mx.cloudflare.net ~all\""
  name     = local.cf_domain
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = local.cf_zone_id
  comment   = "#domain_${local.cf_domain}"
}

# Domain redirect to a URL
# proxied
resource "cloudflare_ruleset" "terraform_managed_resource_ruleset_redirect1" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_dynamic_redirect"
  zone_id = local.cf_zone_id
  rules {
    action = "redirect"
    action_parameters {
      from_value {
        preserve_query_string = false
        status_code           = 302
        target_url {
          value = local.redirect_to_URL
        }
      }
    }
    description = "Redirect to a Different Domain"
    enabled     = true
    expression  = "(http.host eq \"${local.cf_domain}\") or (http.host wildcard \"*.${local.cf_domain}\")"
  }
}