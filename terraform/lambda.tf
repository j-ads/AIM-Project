resource "aws_iam_policy" "unused_eips" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1598854465023",
      "Action": "logs:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "Stmt1598854510488",
      "Action": [
        "ec2:DescribeAddresses"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "Stmt1598854605238",
      "Action": [
        "ses:SendEmail"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role" "unused_eips_role" {
  name = "unused_eip_role"

  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "unused_eips_attach" {
  role       = aws_iam_role.unused_eips_role.name
  policy_arn = aws_iam_policy.unused_eips.arn
}


data "archive_file" "init" {
  type        = "zip"
  source_file  = "unused-eips.py"
  output_path = "unused-eips.zip"
}

# Create a lambda function

resource "aws_lambda_function" "unused_eips" {
  filename                       = data.archive_file.init.output_path
  function_name                  = "unused-eip-demo"
  role                           = aws_iam_role.unused_eips_role.arn
  handler                        = "unused-eips.lambda_handler"
  source_code_hash               = filebase64sha256(data.archive_file.init.output_path)
  
  runtime                        = "python3.8"
  environment {
    variables = {
      SOURCE_EMAIL = "angelmolinabarea@gmail.com",
      DEST_EMAIL   = "angelmolinabarea@gmail.com"
    }
  }
}

resource "aws_cloudwatch_event_rule" "unused_eips" {
  name        = "unused_eips"
  description = "find unused_eips"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "unused_eips" {
  rule      = aws_cloudwatch_event_rule.unused_eips.name
  target_id = "SendsUnusedEIPs"
  arn       = aws_lambda_function.unused_eips.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.unused_eips.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.unused_eips.arn
}

