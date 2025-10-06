variable "queue_names" {
  description = "List of main SQS queue names (DLQs will be created with -dlq suffix)."
  type        = list(string)
}

variable "max_receive_count" {
  description = "Number of receives before message is sent to DLQ."
  type        = number
  default     = 5
}

variable "queue_defaults" {
  description = "Default SQS settings for main and DLQ queues."
  type = object({
    visibility_timeout_seconds = number
    message_retention_seconds  = number
    delay_seconds              = number
    receive_wait_time_seconds  = number
  })
  default = {
    visibility_timeout_seconds = 30
    message_retention_seconds  = 345600
    delay_seconds              = 0
    receive_wait_time_seconds  = 0
  }
}

variable "create_roles" {
  description = "If true, create IAM roles for consume and write policies (extra credit)."
  type        = bool
  default     = false
}
