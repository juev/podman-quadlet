#!/usr/bin/env bash
set -euo pipefail

echo "configuring sns/sqs"
LOCALSTACK_HOST=localhost
AWS_REGION=us-east-1
LOCALSTACK_DUMMY_ID=000000000000

create_queue() {
  awslocal --endpoint-url=http://${LOCALSTACK_HOST}:4566 sqs create-queue --queue-name "$1"
}

create_topic() {
  awslocal --endpoint-url=http://${LOCALSTACK_HOST}:4566 sns create-topic --name "$1"
}

link_queue_and_topic() {
  awslocal --endpoint-url=http://${LOCALSTACK_HOST}:4566 sns subscribe \
    --topic-arn "$1" --protocol sqs --notification-endpoint "$2"
}

arn() { echo "arn:aws:sns:${AWS_REGION}:${LOCALSTACK_DUMMY_ID}:$1"; }

# Topics
for T in payments-local-topic syncing-server-local-topic auth-local-topic \
         files-local-topic analytics-local-topic revisions-server-local-topic \
         scheduler-local-topic; do
  echo "creating topic $T"
  create_topic "$T"
done

# Queues
for Q in analytics-local-queue auth-local-queue files-local-queue \
         syncing-server-local-queue revisions-server-local-queue \
         scheduler-local-queue; do
  echo "creating queue $Q"
  create_queue "$Q"
done

# Links
link_queue_and_topic "$(arn payments-local-topic)" "$(arn analytics-local-queue)"
link_queue_and_topic "$(arn payments-local-topic)" "$(arn auth-local-queue)"
link_queue_and_topic "$(arn auth-local-topic)" "$(arn auth-local-queue)"
link_queue_and_topic "$(arn files-local-topic)" "$(arn auth-local-queue)"
link_queue_and_topic "$(arn revisions-server-local-topic)" "$(arn auth-local-queue)"
link_queue_and_topic "$(arn syncing-server-local-topic)" "$(arn auth-local-queue)"
link_queue_and_topic "$(arn auth-local-topic)" "$(arn files-local-queue)"
link_queue_and_topic "$(arn syncing-server-local-topic)" "$(arn files-local-queue)"
link_queue_and_topic "$(arn syncing-server-local-topic)" "$(arn syncing-server-local-queue)"
link_queue_and_topic "$(arn files-local-topic)" "$(arn syncing-server-local-queue)"
link_queue_and_topic "$(arn auth-local-topic)" "$(arn syncing-server-local-queue)"
link_queue_and_topic "$(arn syncing-server-local-topic)" "$(arn revisions-server-local-queue)"
link_queue_and_topic "$(arn revisions-server-local-topic)" "$(arn revisions-server-local-queue)"

echo "sns/sqs setup complete"
