
module "cloudfront_acm" {
  for_each = toset(var.external_albs)
  source   = "terraform-aws-modules/acm/aws"
  version  = "5.1.0"

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


resource "aws_cloudfront_distribution" "main" {
  for_each = toset(var.external_albs)
  origin {
    domain_name = data.aws_lb.external_app_alb[each.value].dns_name
    origin_id   = replace(each.value, ".", "-")

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = replace(each.value, ".", "-")
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "CloudFront distribution for ELB origin"

  aliases = [
    each.value,
    "*.${each.value}"
  ]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.cloudfront_acm[each.value].acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  http_version = "http2"

}

resource "aws_route53_record" "wildcard" {
  for_each = toset(var.external_albs)
  zone_id  = data.aws_route53_zone.external[each.value].id
  name     = "*.${each.value}"
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.main[each.value].domain_name
    zone_id                = aws_cloudfront_distribution.main[each.value].hosted_zone_id
    evaluate_target_health = true
  }
}
