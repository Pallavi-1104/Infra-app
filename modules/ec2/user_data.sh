#!/bin/bash
# Install Docker and ECS agent
yum update -y
yum install -y docker
service docker start

# Enable ECS agent at boot and set cluster name
echo "ECS_CLUSTER=my-ecs-cluster" >> /etc/ecs/ecs.config
echo "ECS_BACKEND_HOST=" >> /etc/ecs/ecs.config

# Start the ECS agent
start ecs
