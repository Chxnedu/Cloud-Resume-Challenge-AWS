variable "s3_object_ownership" {
  type = string
  default = "BucketOwnerEnforced"
  description = "specifies ownership of objects in bucket"
}

variable "sse_algorithm" {
  type = string
  default = "AES256"
  description = "which algorithm do you want to use"
}