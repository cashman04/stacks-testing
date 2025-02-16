data "aws_route53_zone" "private" {
  for_each = toset(var.private_albs)
  name         = each.value
  private_zone = false
}

module "private_ingress_acm" {
  for_each = toset(var.private_albs)
  source   = "terraform-aws-modules/acm/aws"
  version  = "~> 4.0"

  domain_name = each.value
  zone_id     = data.aws_route53_zone.private[each.value].id

  validation_method = "DNS"

  subject_alternative_names = [
    each.value,
    "*.${each.value}"
  ]

  wait_for_validation = true

  tags = {
    Name = each.value
  }
}


resource "kubernetes_manifest" "private_ingress" {
  for_each = toset(var.private_albs)
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata" = {
      "name"      = "private-${each.value}"
      "namespace" = "ingress-nginx"
      "annotations" = {
        "alb.ingress.kubernetes.io/load-balancer-name"   = replace(each.value, ".", "-") # ALB names cannot contain dots
        "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"          = "instance"
        "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
        "alb.ingress.kubernetes.io/healthcheck-port"     = "traffic-port"
        "alb.ingress.kubernetes.io/healthcheck-path"     = "/healthz"
        "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTPS\":443}, {\"HTTP\":80}]"
        "alb.ingress.kubernetes.io/certificate-arn"      = tostring(module.private_ingress_acm[each.key].acm_certificate_arn) # tostring needed due to random bug and TF not taking it as a string
        "alb.ingress.kubernetes.io/ssl-policy"           = "ELBSecurityPolicy-TLS13-1-2-2021-06"
        "alb.ingress.kubernetes.io/inbound-cidrs"        = join(", ", var.private_alb_inbound_cidrs) # Value has to be string, not list
        "alb.ingress.kubernetes.io/actions.ssl-redirect" = jsonencode({
          "Type" = "redirect",
          "RedirectConfig" = {
            "Protocol"   = "HTTPS",
            "Port"       = "443",
            "StatusCode" = "HTTP_301"
          }
        })
      }
      "labels" = {
        "ingress-class" = "private-ingress"
      }
    }
    "spec" = {
      "ingressClassName" = "alb"
      "rules" = [
        {
          "host" = "*.${each.value}"
          "http" = {
            "paths" = [
              {
                "path"     = "/"
                "pathType" = "Prefix"
                "backend" = {
                  "service" = {
                    "name" = "ssl-redirect"
                    "port" = { "name" = "use-annotation" }
                  }
                }
              },
              {
                "path"     = "/"
                "pathType" = "Prefix"
                "backend" = {
                  "service" = {
                    "name" = "ingress-nginx-controller"
                    "port" = { "number" = 80 }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }

  depends_on = [module.private_ingress_acm]
}
