✨ DevOps CI/CD Simple Blog Project Documentation
<p align="center"><strong>Flask App • Docker • Jenkins • AWS EC2 • Prometheus • Grafana • Automation</strong></p>

📌 1. Project Overview

This project demonstrates a complete end-to-end DevOps CI/CD pipeline for a simple Blog web application using Flask, Docker, Jenkins, and AWS EC2, including:

CI/CD using Jenkins

Automated Docker image build & deployment

GitHub webhook triggers

Shell-script automation

Cron-based backup

Monitoring with Prometheus, Node Exporter & Grafana

🚀 2. Tech Stack

Category	                Tools

Source Control	        Git, GitHub (webhooks for CI)
CI/CD	Jenkins         Pipeline
Application	        Python Flask
Containerization	Docker, Docker Hub
Infrastructure	        AWS EC2 (Ubuntu 22.04)
Monitoring	        Prometheus, Node Exporter, Grafana
Automation	        Bash scripts, Cron

🏗️ 3. Architecture & EC2 Setup

Architecture Flow

<p align="center"> GitHub → Jenkins EC2 → Docker Hub → App EC2 → Monitoring EC2 (Prometheus + Grafana) </p>

Recommended EC2 Instances

Component	Instance Type	Notes
Jenkins Server	t3.micro	Runs Jenkins + Docker
App Server	t3.micro	Hosts Flask App via Docker + Prometheus, Grafana


📂 4. Repository Structure

blog-devops-project/
│
├─ app/
│  ├─ app.py
│  ├─ templates/
│  ├─ static/
│  └─ requirements.txt
│
├─ Dockerfile
├─ docker-compose.yml
├─ Jenkinsfile
│
├─ scripts/
│  ├─ deploy.sh
│  └─ backup_db.sh
│
└─ README.md

⚙️ 5. systemd & Cron Configuration

Node Exporter

Installed at: /usr/local/bin/node_exporter

Managed using systemd

Cron Backup Job

Edit crontab:

crontab -e


Add daily backup at 2 AM:

0 2 * * * /opt/blog/scripts/backup_db.sh >> /var/log/backup_db.log 2>&1

📊 6. Monitoring Setup (Prometheus, Node Exporter, Grafana)

Node Exporter

Installed on App & Jenkins EC2

Exposes: http://<server>:9100/metrics

Prometheus Scrape Config

Add inside prometheus.yml:

scrape_configs:
  - job_name: "node"
    static_configs:
      - targets:
          - "APP_SERVER_PRIVATE_IP:9100"
          - "JENKINS_SERVER_PRIVATE_IP:9100"

Grafana

Access: http://<EC2-IP>:3000

Default login: admin / admin

Add Prometheus as data source

Import dashboards (Node Exporter Full)

🔄 7. Step-by-Step CI/CD Workflow

GitHub

Create Repository

Add Webhook:

http://<JENKINS_IP>:8080/github-webhook/


Generate GitHub PAT token for Jenkins

Jenkins Setup

Install Plugins:

Git

Pipeline

Docker

SSH Agent

Add Credentials in Jenkins:

ID	              Purpose
dockerhub-creds	    Push images to Docker Hub
app-ssh	            SSH private key to App Server

CI/CD Flow

Developer pushes code → GitHub

Webhook triggers Jenkins

Jenkins builds Docker image

Push to Docker Hub

SSH to App Server → run deploy.sh

Container runs blog app on port 80

🧪 8. Testing & Validation

Component	                 Check
Docker	               docker ps, docker logs -f <container>
App	               Open browser → http://<APP_PUBLIC_IP>
Database	       SQLite file created, blog posts saved
Backups	Files          appear in /opt/blog/backups
Prometheus	       http://<IP>:9090/targets → node targets UP
Grafana	Dashboards     show real-time metrics

🔧 9. Installation Commands

Docker Installation (Both Jenkins & App EC2)

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update
sudo apt install -y docker.io

sudo systemctl enable --now docker
sudo usermod -aG docker $USER

Java Installation (for Jenkins)

sudo apt update
sudo apt install -y fontconfig openjdk-17-jre
java -version

Jenkins Installation

sudo apt update
sudo apt install -y ca-certificates curl gnupg

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
| sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
| sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins

sudo systemctl enable --now jenkins


Jenkins UI → http://<IP>:8080

Prometheus Installation (Monitoring EC2)

sudo useradd -rs /bin/false prometheus
cd /opt
wget https://github.com/prometheus/prometheus/releases/download/v2.51.0/prometheus-2.51.0.linux-amd64.tar.gz
tar -xvf prometheus-2.51.0.linux-amd64.tar.gz

sudo mv prometheus-2.51.0.linux-amd64 /etc/prometheus
sudo mkdir -p /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

Prometheus Systemd Service

sudo tee /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus Monitoring
After=network-online.target

[Service]
User=prometheus
ExecStart=/etc/prometheus/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF


Start Prometheus:

sudo systemctl daemon-reload
sudo systemctl enable --now prometheus

Node Exporter Installation (Both EC2 Instances)

sudo useradd -rs /bin/false node_exporter
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.7.0.linux-amd64.tar.gz

sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/

Systemd Service

sudo tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF


Start:

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

Grafana Installation

sudo apt update
sudo apt install -y apt-transport-https software-properties-common wget

wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

echo "deb https://packages.grafana.com/oss/deb stable main" \
| sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt update
sudo apt install -y grafana

sudo systemctl daemon-reload
sudo systemctl enable --now grafana-server


Grafana UI:
http://<IP>:3000 (admin / admin)

🔍 10. Verification Commands

Docker
docker --version
docker ps
docker images
docker logs -f <container>

Jenkins

systemctl status jenkins

Prometheus

systemctl status prometheus
curl http://localhost:9090/targets

Node Exporter

systemctl status node_exporter
curl http://localhost:9100/metrics

Grafana

systemctl status grafana-server