# Kraken Platform Engineer Challenge

This repository implements a small end-to-end platform engineering solution using **Terraform** and **Python**.

It includes:
- A **Terraform module** that creates AWS SQS queues with corresponding Dead-Letter Queues (DLQs), IAM policies, and optional IAM roles.
- A **Python utility** that retrieves message counts from SQS queues and their DLQs using `boto3`.
- Unit tests that mock AWS behavior using the [moto](https://github.com/getmoto/moto) library.


## Project Structure
```text
.
├── modules # Terraform reusable components
│   └── sqs
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── versions.tf
│       └── README.md
├── examples # Example Terraform usage
│   └── basic
│       └── main.tf
├── python # Python utility + tests
│   ├── sqs_queues.py
│   ├── __init__.py
│   ├── README.md
│   └── tests
│       └── test_sqs_queues.py
├── provider.tf # Global Terraform provider config
├── variables.tf # Shared Terraform variables
└── README.md # This documentation file
```

## Run & Test

### 1. Deploy infrastructure
```bash
cd examples/basic
terraform init
terraform apply -auto-approve
```

**This will create:**

- Two SQS queues: priority-10, priority-100
- Two corresponding DLQs: priority-10-dlq, priority-100-dlq
- IAM policies for reading/writing queue messages
- Optional IAM roles (if create_roles = true)


### 2. Verify in AWS Console

Navigate to Amazon SQS -> Queues in region us-east-1.
You should see all four queues created by Terraform.


### 3. Run the Python Utility

```bash
cd ../../python
pip install boto3 moto pytest
python sqs_queues.py priority-10 priority-100 --json
```

**Sample output:**

```json
[
  {
    "queue": "priority-10",
    "main_counts": {"visible": 0, "inflight": 0, "delayed": 0},
    "dlq": "priority-10-dlq",
    "dlq_counts": {"visible": 0, "inflight": 0, "delayed": 0}
  }
]
```


### 4. Send a Test Message

```bash
aws sqs send-message --queue-url $(aws sqs get-queue-url --queue-name priority-10 --query 'QueueUrl' --output text) --message-body 'Hello Kraken!'
```

**Then re-run:**

```bash
python sqs_queues.py priority-10
```

**Expected output:**

```yaml
priority-10: {'visible': 1, 'inflight': 0, 'delayed': 0}
  priority-10-dlq: {'visible': 0, 'inflight': 0, 'delayed': 0}
```


### 5. Run Unit Tests

From the repository root:

```bash
pytest python/tests
```

**Expected:**

```bash
collected 1 item
python/tests/test_sqs_queues.py .                                      [100%]
```


### 6. Clean Up

**Destroy all AWS resources to avoid charges:**

```bash
cd examples/basic
terraform destroy -auto-approve
```


## Technical Notes

**Terraform**

- Tested with Terraform ≥ 1.0 and AWS provider ≥ 3.48
- The module is fully self-contained and reusable
- Supports optional IAM role creation via `create_roles` flag

**Python**

- Compatible with Python ≥ 3.8
- Uses boto3 for AWS operations
- Supports both CLI and import-as-module usage

**Testing**

- Uses pytest + moto to mock SQS behavior
- Provides a clean, reproducible test environment


## Requirements
- Terraform ≥ 1.0
- Python ≥ 3.8
- AWS CLI configured with valid credentials


## Deliverables Summary

| Component | Technology | Description |
|------------|-------------|-------------|
| **Terraform Module** | HCL | Creates SQS queues, DLQs, IAM policies, and optional roles |
| **Example** | Terraform | Demonstrates module usage (`examples/basic`) |
| **Python Script** | Python (`boto3`) | Fetches message counts for queues and DLQs |
| **Tests** | `pytest` + `moto` | Unit testing with AWS mocks |
| **Docs** | Markdown | Root + module + Python READMEs |


## License

This challenge solution is provided for technical evaluation purposes only.

---

Author: Alena Shiltsina