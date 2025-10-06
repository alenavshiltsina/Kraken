output "queue_arns" {
  value = concat([for q in var.queue_names : aws_sqs_queue.main[q].arn],
  [for q in var.queue_names : aws_sqs_queue.dlq[q].arn])
}

output "consume_policy_arn" {
  value = aws_iam_policy.consume.arn
}

output "write_policy_arn" {
  value = aws_iam_policy.write.arn
}

output "consume_role_arn" {
  value = try(aws_iam_role.consume[0].arn, null)
}

output "write_role_arn" {
  value = try(aws_iam_role.write[0].arn, null)
}
