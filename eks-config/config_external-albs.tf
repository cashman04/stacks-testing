data "aws_route53_zone" "external" {
  for_each     = toset(var.external_albs)
  name         = each.value
  private_zone = false
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

module "external_ingress_acm" {
  for_each = toset(var.external_albs)
  source   = "terraform-aws-modules/acm/aws"
  version  = "~> 4.0"

  domain_name = each.value
  zone_id     = data.aws_route53_zone.external[each.value].id

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


resource "kubernetes_manifest" "external_ingress" {
  for_each = toset(var.external_albs)
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata" = {
      "name"      = "external-${each.value}"
      "namespace" = "ingress-nginx"
      "annotations" = {
        "alb.ingress.kubernetes.io/load-balancer-name"   = replace(each.value, ".", "-")
        "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"          = "instance"
        "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
        "alb.ingress.kubernetes.io/healthcheck-port"     = "traffic-port"
        "alb.ingress.kubernetes.io/healthcheck-path"     = "/healthz"
        "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTPS\":443}, {\"HTTP\":80}]"
        "alb.ingress.kubernetes.io/certificate-arn"      = tostring(module.external_ingress_acm[each.key].acm_certificate_arn)
        "alb.ingress.kubernetes.io/ssl-policy"           = "ELBSecurityPolicy-TLS13-1-2-2021-06"
        "alb.ingress.kubernetes.io/inbound-cidrs"        = tostring(data.aws_ec2_managed_prefix_list.cloudfront.id)
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
        "ingress-class" = "internal-ingress"
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

  depends_on = [module.external_ingress_acm]
}
