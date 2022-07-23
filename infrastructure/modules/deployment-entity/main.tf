# ----------------------------------------------------------------------------------------------------------------------
# User
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_user" "deployment" {
  name = "deploy-${var.name}"
  path = "/deployment/"
}

resource "aws_iam_user_policy" "assume_role" {
  name   = "AssumeRoles"
  user   = aws_iam_user.deployment.id
  policy = data.aws_iam_policy_document.user_assume_roles.json
}

data "aws_iam_policy_document" "user_assume_roles" {
  statement {
    sid       = "AssumeDeploymentRole"
    actions   = ["sts:AssumeRole", "sts:TagSession"]
    resources = [aws_iam_role.deployment.arn]
  }

  statement {
    sid       = "AssumeRemotestateRole"
    actions   = ["sts:AssumeRole", "sts:TagSession"]
    resources = [var.remotestate_role]
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Role
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "deployment" {
  name               = "deploy-${var.name}"
  description        = "Deployment role for '${var.name}'"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.deployment.arn]
    }
  }
}