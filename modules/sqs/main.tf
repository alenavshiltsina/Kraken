locals {
  dlq_suffix      = "-dlq"
  all_queue_names = flatten([for q in var.queue_names : [q, format("%s%s", q, local.dlq_suffix)]])
}

resource "aws_sqs_queue" "dlq" {
  for_each = { for q in var.queue_names : q => format("%s%s", q, local.dlq_suffix) }

  name                       = each.value
  visibility_timeout_seconds = var.queue_defaults.visibility_timeout_seconds
  message_retention_seconds  = var.queue_defaults.message_retention_seconds
  delay_seconds              = var.queue_defaults.delay_seconds
  receive_wait_time_seconds  = var.queue_defaults.receive_wait_time_seconds
}

resource "aws_sqs_queue" "main" {
  for_each = toset(var.queue_names)

  name                       = each.value
  visibility_timeout_seconds = var.queue_defaults.visibility_timeout_seconds
  message_retention_seconds  = var.queue_defaults.message_retention_seconds
  delay_seconds              = var.queue_defaults.delay_seconds
  receive_wait_time_seconds  = var.queue_defaults.receive_wait_time_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = var.max_receive_count
  })
}

resource "aws_iam_policy" "consume" {
  name        = "sqs-consume-${replace(join("-", var.queue_names), ":", "-")}"
  description = "Allow Receive/Delete on module-created SQS queues"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ChangeMessageVisibility"]
      Resource = concat(
        [for q in var.queue_names : aws_sqs_queue.main[q].arn],
        [for q in var.queue_names : aws_sqs_queue.dlq[q].arn]
      )
    }]
  })
}

resource "aws_iam_policy" "write" {
  name        = "sqs-write-${replace(join("-", var.queue_names), ":", "-")}"
  description = "Allow SendMessage on main SQS queues"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:SendMessage"]
      Resource = [for q in var.queue_names : aws_sqs_queue.main[q].arn]
    }]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "consume" {
  count = var.create_roles ? 1 : 0
  name  = "sqs-consume-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "consume_attach" {
  count      = var.create_roles ? 1 : 0
  role       = aws_iam_role.consume[0].name
  policy_arn = aws_iam_policy.consume.arn
}

resource "aws_iam_role" "write" {
  count              = var.create_roles ? 1 : 0
  name               = "sqs-write-role"
  assume_role_policy = aws_iam_role.consume[0].assume_role_policy
}

resource "aws_iam_role_policy_attachment" "write_attach" {
  count      = var.create_roles ? 1 : 0
  role       = aws_iam_role.write[0].name
  policy_arn = aws_iam_policy.write.arn
}
