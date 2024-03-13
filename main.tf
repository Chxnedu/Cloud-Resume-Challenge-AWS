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

resource "aws_s3_bucket_public_access_block" "chxnedu-resume-crc" {
  bucket = aws_s3_bucket.chxnedu-resume-crc.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
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
  depends_on = [ aws_s3_bucket_public_access_block.chxnedu-resume-crc ]
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

resource "aws_s3_object" "favicon" {
  key          = "favicon.png"
  bucket       = aws_s3_bucket.chxnedu-resume-crc.id
  source       = "./Files/favicon.png"
  content_type = "image/png"
  depends_on = [
    aws_s3_bucket_website_configuration.resume-site
  ]
}

resource "aws_s3_object" "css" {
  key          = "css"
  bucket       = aws_s3_bucket.chxnedu-resume-crc.id
  source       = "./Files/css/"
  depends_on = [
    aws_s3_bucket_website_configuration.resume-site
  ]
}

resource "aws_s3_object" "images" {
  key          = "images"
  bucket       = aws_s3_bucket.chxnedu-resume-crc.id
  source       = "./Files/images/"
  depends_on = [
    aws_s3_bucket_website_configuration.resume-site
  ]
}

resource "aws_s3_object" "inc" {
  key          = "inc"
  bucket       = aws_s3_bucket.chxnedu-resume-crc.id
  source       = "./Files/inc/"
  depends_on = [
    aws_s3_bucket_website_configuration.resume-site
  ]
}

resource "aws_s3_object" "js" {
  key          = "js"
  bucket       = aws_s3_bucket.chxnedu-resume-crc.id
  source       = "./Files/js/"
  content_type = "text/html"
  depends_on = [
    aws_s3_bucket_website_configuration.resume-site
  ]
}


output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.resume-site.website_endpoint
}

resource "aws_acm_certificate" "domain-cert" {
  domain_name               = "chxnedu.online"
  subject_alternative_names = ["*.chxnedu.online"]
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
    cached_methods = [ "GET", "HEAD" ]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Resume Site Distribution"
  default_root_object = "index.html"
  aliases             = [ "resume.chxnedu.online","chxnedu.online" ]
  price_class         = "PriceClass_All"

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.domain-cert.arn
    ssl_support_method = "sni-only"
  }

  depends_on = [
    aws_s3_bucket_website_configuration.resume-site,
    aws_acm_certificate.domain-cert
  ]
}
