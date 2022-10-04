terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.33.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = myaccesskey
  secret_key = mysecretkey
}

resource "aws_s3_bucket" "chxnedu-resume-crc" {
  bucket = "chxnedu-resume-crc"
}

resource "aws_s3_bucket_policy" "public-access" {
  bucket = aws_s3_bucket.chxnedu-resume-crc.id
  policy = file(policy.json)
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
  key = "index.html"
  bucket = aws_s3_bucket.chxnedu-resume-crc.id
  source = "./Files/index.html"
  content_type = "text/html"
  depends_on = [
    aws_s3_bucket_website_configuration.resume-site
  ]
}

resource "aws_s3_object" "styles" {
  key = "styles.css"
  bucket = aws_s3_bucket.chxnedu-resume-crc.id
  source = "./Files/styles.css"
  content_type = "text/css"
  depends_on = [
    aws_s3_bucket_website_configuration.resume-site
  ]
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.resume-site.website_endpoint
}

