#S3 Bucket creation

resource "aws_s3_bucket" "tfbucket1" {
  bucket = "tfbuckett"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["http://tfbuckett.s3.eu-central-1.amazonaws.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
  
  tags = {
    Name = "staticFiles"
    Project = "Multi"
  }
}
