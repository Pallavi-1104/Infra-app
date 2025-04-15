#!/bin/bash
# This script can be used to configure your EC2 instances on startup

# Update packages and install necessary software
yum update -y
yum install -y docker

# Start Docker service
service docker start
