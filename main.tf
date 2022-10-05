terraform {
  backend "remote" {
    organization = "chxnedu-crc"

    workspaces {
      name = "Prod-Env"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "chxnedu-resume-crc" {
  bucket = "chxnedu-resume-crc"
}

resource "aws_s3_bucket_policy" "public-access" {
  bucket = aws_s3_bucket.chxnedu-resume-crc.id
  policy = <<-EOS
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::chxnedu-resume-crc/*"
        }
    ]
}
EOS
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.chxnedu-resume-crc.id
  rule {
    object_ownership = var.s3_object_ownership
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.chxnedu-resume-crc.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_website_configuration" "resume-site" {
  bucket = aws_s3_bucket.chxnedu-resume-crc.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

resource "aws_s3_object" "index" {
  key          = "index.html"
  bucket       = aws_s3_bucket.chxnedu-resume-crc.id
  source       = "./Files/index.html"
  content_type = "text/html"
  depends_on = [
    aws_s3_bucket_website_configuration.resume-site
  ]
}

resource "aws_s3_object" "styles" {
  key          = "styles.css"
  bucket       = aws_s3_bucket.chxnedu-resume-crc.id
  source       = "./Files/styles.css"
  content_type = "text/css"
  depends_on = [
    aws_s3_bucket_website_configuration.resume-site
  ]
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.resume-site.website_endpoint
}

resource "aws_acm_certificate" "domain-cert" {
  domain_name               = "chxnedu.com"
  subject_alternative_names = ["*.chxnedu.com"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  s3_origin_id = "crc-resume-origin"
}

resource "aws_cloudfront_distribution" "s3resume-distrubution" {
  origin {
    domain_name = aws_s3_bucket.chxnedu-resume-crc.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Resume Site Distribution"
  default_root_object = "index.html"
  aliases             = "resume.chxnedu.com"
  price_class         = "PriceClass_All"

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.domain-cert.arn
  }
  depends_on = [
    aws_s3_bucket_website_configuration.resume-site,
    aws_acm_certificate.domain-cert
  ]
}
