import argparse
import boto3
import json
import sys
from typing import List, Dict, Any
from botocore.exceptions import ClientError


def _get_queue_url(sqs, name: str) -> str:
    """Return queue URL for a given name."""
    return sqs.get_queue_url(QueueName=name)["QueueUrl"]


def _get_dlq_name(sqs, queue_url: str) -> str:
    """Extract DLQ name from RedrivePolicy."""
    attrs = sqs.get_queue_attributes(QueueUrl=queue_url, AttributeNames=["RedrivePolicy"]).get("Attributes", {})
    policy = attrs.get("RedrivePolicy")
    if not policy:
        return None
    try:
        data = json.loads(policy)
        arn = data.get("deadLetterTargetArn", "")
        return arn.split(":")[-1] if arn else None
    except Exception:
        return None


def _get_counts(sqs, queue_url: str) -> Dict[str, int]:
    """Fetch message counts for a given queue URL."""
    attrs = sqs.get_queue_attributes(
        QueueUrl=queue_url,
        AttributeNames=[
            "ApproximateNumberOfMessages",
            "ApproximateNumberOfMessagesNotVisible",
            "ApproximateNumberOfMessagesDelayed",
        ],
    )["Attributes"]
    return {
        "visible": int(attrs.get("ApproximateNumberOfMessages", 0)),
        "inflight": int(attrs.get("ApproximateNumberOfMessagesNotVisible", 0)),
        "delayed": int(attrs.get("ApproximateNumberOfMessagesDelayed", 0)),
    }


def get_queues_message_totals(queues: List[str]) -> List[Dict[str, Any]]:
    """Return counts for each main queue and its DLQ."""
    sqs = boto3.client("sqs")
    results = []

    for name in queues:
        entry = {"queue": name}
        try:
            q_url = _get_queue_url(sqs, name)
            entry["main_counts"] = _get_counts(sqs, q_url)

            dlq_name = _get_dlq_name(sqs, q_url) or f"{name}-dlq"
            try:
                dlq_url = _get_queue_url(sqs, dlq_name)
                entry["dlq"] = dlq_name
                entry["dlq_counts"] = _get_counts(sqs, dlq_url)
            except ClientError:
                entry["dlq"] = dlq_name
                entry["dlq_counts"] = {"visible": 0, "inflight": 0, "delayed": 0}

        except ClientError as e:
            entry["error"] = str(e)
        results.append(entry)

    return results


def main():
    """Command-line entrypoint."""
    parser = argparse.ArgumentParser(description="Display SQS queue message counts.")
    parser.add_argument("queues", nargs="+", help="List of main SQS queue names.")
    parser.add_argument("--json", action="store_true", help="Output JSON format.")
    args = parser.parse_args()

    data = get_queues_message_totals(args.queues)
    if args.json:
        print(json.dumps(data, indent=2))
    else:
        for item in data:
            if "error" in item:
                print(f"ERROR {item['queue']}: {item['error']}", file=sys.stderr)
                continue
            print(f"{item['queue']}: {item['main_counts']}")
            print(f"  {item['dlq']}: {item['dlq_counts']}")


if __name__ == "__main__":
    main()
