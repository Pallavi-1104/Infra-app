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


 /*Create directories
mkdir -p /etc/prometheus /var/lib/prometheus /etc/grafana /opt/node_exporter

# Download and setup Prometheus
cd /opt
wget https://github.com/prometheus/prometheus/releases/download/v2.48.1/prometheus-2.48.1.linux-amd64.tar.gz
tar -xzf prometheus-2.48.1.linux-amd64.tar.gz
mv prometheus-2.48.1.linux-amd64/* /etc/prometheus/
cp /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml.bak

# Create Prometheus systemd service
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
User=root
ExecStart=/etc/prometheus/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

# Install Grafana
cd /opt
wget https://dl.grafana.com/oss/release/grafana-10.2.3-1.x86_64.rpm
yum install -y grafana-10.2.3-1.x86_64.rpm
systemctl enable grafana-server
systemctl start grafana-server

# Install Node Exporter
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar -xzf node_exporter-1.8.1.linux-amd64.tar.gz
mv node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/

# Create Node Exporter systemd service
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter*/

mkdir -p /ecs/prometheus_config
cat <<EOF > /ecs/prometheus_config/prometheus.yml
$(cat /etc/ecs/prometheus/prometheus.yml)
EOF

#!/bin/bash
mkdir -p /ecs/mongo-data
