# Python Utility – sqs_queues.py

This Python utility retrieves **message counts** from AWS **SQS queues** and their corresponding **Dead-Letter Queues (DLQs)** using the `boto3` library.  
It can be run via the **command line** or imported as a **Python module**.


## Features
- Fetches message counts (`visible`, `inflight`, `delayed`) for main and DLQ queues  
- Supports both CLI and import-based usage  
- Outputs in JSON or human-readable format  
- Includes unit tests powered by **pytest** and **moto** (AWS mocking library)


## Inputs

| Name | Type | Required | Description |
|------|------|-----------|-------------|
| `queues` | `list(string)` | Yes | List of SQS queue names to inspect |
| `--json` | flag | Optional | Output results in JSON format when used from CLI |


## Outputs

| Format | Description |
|---------|-------------|
| CLI | Prints queue message counts to standard output |
| JSON | Returns structured queue data including DLQ counts |
| Python | Returns a list of dictionaries with counts and queue metadata |


## Example Usage

### CLI Mode

```bash
python sqs_queues.py priority-10 priority-100 --json
```

**Sample Output:**

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

**Import as a Module**

```python
from sqs_queues import get_queues_message_totals

results = get_queues_message_totals(["priority-10", "priority-100"])
print(results)
```

**Testing**

```bash
pytest tests
```

**Expected Output:**

```bash
collected 1 item
tests/test_sqs_queues.py .                                         [100%]
```

## Requirements

| Dependency | Version | Purpose |
|-------------|----------|----------|
| **Python** | ≥ 3.8 | Required runtime |
| **boto3** | Latest | AWS SDK for Python |
| **moto** | Latest | Mock AWS services for testing |
| **pytest** | Latest | Unit testing framework |

**Install dependencies:**
```bash
pip install boto3 moto pytest
```


## Deliverables

| Component | Description |
|------------|-------------|
| **sqs_queues.py** | Main utility script for fetching SQS message counts |
| **__init__.py** | Makes the utility importable as a module |
| **tests/** | Contains `pytest`-based unit tests using `moto` |
| **README.md** | Documentation for Python utility |

---

Author: Alena Shiltsina.
Module: part of the Kraken Platform Engineer Challenge.