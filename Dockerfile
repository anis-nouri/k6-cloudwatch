# Use the official K6 image as the base image
FROM debian:latest as build

RUN apt-get update &&  \
    apt-get install -y ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb && \
    dpkg -i -E amazon-cloudwatch-agent.deb && \
    rm -rf /tmp/* && \
    rm -rf /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard && \
    rm -rf /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl && \
    rm -rf /opt/aws/amazon-cloudwatch-agent/bin/config-downloader

FROM grafana/k6:latest

USER root

RUN apk update && apk add bash

COPY --from=build /tmp /tmp

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

COPY --from=build /opt/aws/amazon-cloudwatch-agent /opt/aws/amazon-cloudwatch-agent

COPY /aws_con/config /root/.aws/config

COPY statsd.json /opt/aws/amazon-cloudwatch-agent/bin/default_linux_config.json
COPY statsd.json /opt/aws/amazon-cloudwatch-agent/etc/statsd.json

COPY /scripts/script.js .

ENV RUN_IN_CONTAINER="True"

# Start k6 and CloudWatch Agent in the background using a shell script
COPY start.sh .
RUN chmod +x start.sh



ENTRYPOINT ["/bin/bash","start.sh" ]

