output "user_arn" {
  value = aws_iam_user.deployment.arn
}

output "role_arn" {
  value = aws_iam_role.deployment.arn
}

output "role_id" {
  value = aws_iam_role.deployment.id
}