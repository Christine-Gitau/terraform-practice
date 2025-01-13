terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "Cloudfront S3 OAC"
  description                       = "Cloudfront S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {

  aliases                         = var.aliases
  comment                         = var.comment
  continuous_deployment_policy_id = var.continuous_deployment_policy_id
  default_root_object             = var.default_root_object
  enabled                         = var.enabled
  http_version                    = var.http_version
  is_ipv6_enabled                 = var.is_ipv6_enabled
  price_class                     = var.price_class
  retain_on_delete                = var.retain_on_delete
  staging                         = var.staging
  wait_for_deployment             = var.wait_for_deployment
  web_acl_id                      = var.web_acl_id
  tags                            = var.tags

  origin {
    domain_name = data.aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id   = "s3_bucket"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }
  default_cache_behavior {
    allowed_methods        = []
    cached_methods         = []
    target_origin_id       = "s3_bucket"
    viewer_protocol_policy = ""
  }
  custom_error_response {
    error_code = 0
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = ["US", "CA"]
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
data "aws_s3_bucket" "s3_bucket" {
  bucket = var.s3_bucket_id
}

