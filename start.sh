#!/bin/bash
mkdir /root/.aws
touch /root/.aws/credentials
touch /root/.aws/config

echo "[AmazonCloudWatchAgent]" > /root/.aws/credentials
echo "aws_access_key_id=$AWS_ACCESS_KEY_ID" >> /root/.aws/credentials
echo "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" >> /root/.aws/credentials

echo "[AmazonCloudWatchAgent]" > /root/.aws/config
echo "region=$AWS_REGION" >> /root/.aws/config

# Start the CloudWatch Agent in the background
/opt/aws/amazon-cloudwatch-agent/bin/start-amazon-cloudwatch-agent &

echo "mriguil"
sleep 10
K6_STATSD_ENABLE_TAGS=true k6 run --out statsd script.js
sleep 100
