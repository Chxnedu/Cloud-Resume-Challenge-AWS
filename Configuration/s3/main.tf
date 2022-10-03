provider "aws" {
  region = "us-east-1"
  access_key = myaccesskey
  secret_key = mysecretkey
}
terraform {
  backend "s3" {
    bucket = "crc-state"
    key = "s3/terraform.tfstate"
    region = "us-east-1"
  }
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
}

resource "aws_s3_object" "index" {
  key = "index.html"
  bucket = aws_s3_bucket.chxnedu-resume-crc.id
  source = "./Files/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "styles" {
  key = "styles.css"
  bucket = aws_s3_bucket.chxnedu-resume-crc.id
  source = "./Files/styles.css"
  content_type = "text/css"
}


