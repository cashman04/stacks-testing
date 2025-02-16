data "aws_lb" "external_app_alb" {
  for_each = toset(var.external_albs)
  name     = replace(each.value, ".", "-")

}

data "aws_route53_zone" "external" {
  for_each     = toset(var.external_albs)
  name         = each.value
  private_zone = false
}


data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}



