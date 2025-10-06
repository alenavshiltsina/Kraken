# SQS Terraform Module

This module provisions **AWS SQS queues** with corresponding **Dead-Letter Queues (DLQs)**, IAM **policies**, and optional IAM **roles** for read/write access.


## Features
- Creates main SQS queues and corresponding DLQs (with `-dlq` suffix)
- Attaches DLQs via `redrive_policy`
- Generates IAM policies for consuming and writing messages
- Optionally creates IAM roles and attaches policies (if `create_roles = true`)


## Inputs

| Name | Type | Default | Description |
|------|------|----------|-------------|
| `region` | `string` | `"us-east-1"` | AWS region for resource deployment |
| `queue_names` | `list(string)` | n/a | List of SQS queue names (DLQs auto-created) |
| `max_receive_count` | `number` | `5` | Max receives before moving message to DLQ |
| `queue_defaults` | `object` | *(defaults provided)* | Default SQS settings for timeout, retention, delay |
| `create_roles` | `bool` | `false` | Whether to create IAM roles for consume/write policies |


## Outputs

| Name | Description |
|------|--------------|
| `queue_arns` | ARNs of all created queues (main + DLQ) |
| `consume_policy_arn` | ARN of IAM policy allowing receive/delete |
| `write_policy_arn` | ARN of IAM policy allowing send message |
| `consume_role_arn` | ARN of optional IAM role for consume policy |
| `write_role_arn` | ARN of optional IAM role for write policy |


## Example Usage

```hcl
module "sqs" {
  source       = "../modules/sqs"
  region       = "us-east-1"
  queue_names  = ["priority-10", "priority-100"]
  create_roles = true
}

```

## Requirements

| Dependency | Version | Purpose |
|-------------|----------|----------|
| **Terraform** | ≥ 1.0 | Required infrastructure as code tool |
| **AWS Provider** | ≥ 3.48 | Required provider for AWS resources |
| **AWS Account** | Any valid account | Needed to create SQS queues, IAM policies, and roles |

**Initialize Terraform:**
```bash
terraform init
```

## Deliverables

| Component | Description |
|------------|-------------|
| **main.tf** | Defines SQS queues, DLQs, IAM policies, and optional roles |
| **variables.tf** | Input variable definitions |
| **outputs.tf** | Exposes ARNs and policy references |
| **versions.tf** | Specifies Terraform and provider versions |

---

Author: Alena Shiltsina
Module: part of the Kraken Platform Engineer Challenge