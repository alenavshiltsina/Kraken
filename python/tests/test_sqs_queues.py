import sys
import os
import json
from moto import mock_aws
import boto3

sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from sqs_queues import get_queues_message_totals

@mock_aws
def test_dlq_counts():
    sqs = boto3.client("sqs", region_name="us-east-1")

    dlq_url = sqs.create_queue(QueueName="orders-dlq")["QueueUrl"]
    dlq_attrs = sqs.get_queue_attributes(
        QueueUrl=dlq_url,
        AttributeNames=["QueueArn"]
    )["Attributes"]

    sqs.create_queue(
        QueueName="orders",
        Attributes={
            "RedrivePolicy": json.dumps({
                "deadLetterTargetArn": dlq_attrs["QueueArn"],
                "maxReceiveCount": 5
            })
        },
    )

    result = get_queues_message_totals(["orders"])
    assert result[0]["queue"] == "orders"
    assert result[0]["dlq"] == "orders-dlq"
    assert "main_counts" in result[0]
    assert "dlq_counts" in result[0]