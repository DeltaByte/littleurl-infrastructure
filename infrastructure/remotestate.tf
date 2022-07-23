# ----------------------------------------------------------------------------------------------------------------------
# State storage
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "remotestate" {
  bucket = "${var.application}-terraform-state"
}

resource "aws_s3_bucket_acl" "state" {
  bucket = aws_s3_bucket.remotestate.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "remotestate" {
  bucket = aws_s3_bucket.remotestate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# remove plans after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "remotestate_plan" {
  bucket = aws_s3_bucket.remotestate.id
  rule {
    id     = "plan"
    status = "Enabled"

    filter {
      prefix = "plan/"
    }

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "remotestate" {
  bucket = aws_s3_bucket.remotestate.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# State storage access
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "remotestate" {
  bucket                  = aws_s3_bucket.remotestate.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "remotestate" {
  depends_on = [aws_s3_bucket.remotestate]
  bucket     = aws_s3_bucket.remotestate.id
  policy     = data.aws_iam_policy_document.remotestate_bucket.json
}

data "aws_iam_policy_document" "remotestate_bucket" {
  statement {
    sid = "DenyIncorrectEncryptionHeader"

    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.remotestate.arn}/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "AES256"
      ]
    }
  }

  statement {
    sid = "DenyUnEncryptedObjectUploads"

    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.remotestate.arn}/*"
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "true"
      ]
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# State lock
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_dynamodb_table" "remotestate_lock" {
  name         = "${var.application}-terraform-lock"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Cross-account access
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "remotestate" {
  for_each = var.environments

  name               = "TerraformRemotestate${title(each.key)}"
  assume_role_policy = data.aws_iam_policy_document.remotestate_assume[each.key].json

  tags = {
    environment = each.key
  }
}

data "aws_iam_policy_document" "remotestate_assume" {
  for_each = var.environments

  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${local.aws_account_ids[each.key]}:root"
      ]
    }

    condition {
      test     = "Null"
      variable = "aws:PrincipalTag/service"
      values = [false]
    }
  }
}

resource "aws_iam_role_policy" "remotestate_access" {
  for_each = var.environments

  name   = "TerraformBackendAccess"
  role   = aws_iam_role.remotestate[each.key].id
  policy = data.aws_iam_policy_document.remotestate_access[each.key].json
}

data "aws_iam_policy_document" "remotestate_access" {
  for_each = var.environments

  statement {
    sid = "DynamoLock"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "dynamodb:LeadingKeys"
      values = [
        "${aws_s3_bucket.remotestate.id}/state/${each.key}/$${aws:PrincipalTag/service, 'INVALID_SERVICE_TAG'}.tfstate",
        "${aws_s3_bucket.remotestate.id}/state/${each.key}/$${aws:PrincipalTag/service, 'INVALID_SERVICE_TAG'}.tfstate-md5",
        "${aws_s3_bucket.remotestate.id}/plan/${each.key}/$${aws:PrincipalTag/service, 'INVALID_SERVICE_TAG'}.tfplan"
      ]
    }

    resources = [aws_dynamodb_table.remotestate_lock.arn]
  }

  statement {
    sid = "S3ListObjects"

    actions = [
      "s3:ListBucket"
    ]

    resources = [aws_s3_bucket.remotestate.arn]
  }

  statement {
    sid = "S3GetAndPutObjects"

    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.remotestate.arn}/state/${each.key}/$${aws:PrincipalTag/service, 'INVALID_SERVICE_TAG'}.tfstate",
      "${aws_s3_bucket.remotestate.arn}/plan/${each.key}/$${aws:PrincipalTag/service, 'INVALID_SERVICE_TAG'}.tfplan"
    ]
  }
}
