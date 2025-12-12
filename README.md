DevOps CI/CD Simple Blog Project Documentation

1. **Project Overview**
This project demonstrates a complete end-to-end DevOps pipeline including a Flask application, Docker containerization, Jenkins CI/CD, automated deployments, cron-based backups, and monitoring using Prometheus, Node Exporter, and Grafana.

**Tech Stack:**
Source Control:  Git, GitHub (Code hosting, version control, webhook triggers for CI)
CI/CD Automation: Jenkins on AWS EC2 (Automates build, Docker image creation, push to Docker Hub and deployment)
Application: Python(Flask)(Lightweight web server used to demonstrate deployment pipeline)
Containerization: Docker, Docker Hub Registry (Packages and ships the application as immutable images)
Infrastructure: AWS EC2(ubuntu server) (Runs Jenkins, Application Docker Host, Prometheus and Grafana)
Monitoring: Prometheus+Node Exporter and Grafana (Infrastructure & application performance monitoring and dashboard visualization)
Automation & Scripting: Bash Shell Scripts (Deployment automation, backup scripts, log rotation and cron jobs)
Job Scheduling: Cron(Linux Crontab) (Automated task scheduling for backups and housekeeping)

3. **Architecture & Instance Sizing**
Architecture Flow:
GitHub (Webhook) → Jenkins EC2 → Docker Hub → App EC2 (Docker Deployment) → Monitoring EC2 (Prometheus + Grafana).
Recommended EC2 Instances:
- Jenkins: t3.micro
- App Server: t3.micro
AMI: Ubuntu 22.04

3. **Repository Structure**
blog-devops-project/
├─ app/
│  ├─ app.py
│  ├─ templates/
│  ├─ static/
│  └─ requirements.txt
├─ Dockerfile
├─ docker-compose.yml
├─ Jenkinsfile
├─ scripts/
│  ├─ deploy.sh
│  └─ backup_db.sh
└─ README.md
    
**4. Systemd and Cron Notes**
Node Exporter and Prometheus run as systemd services. Cron runs backups daily.
Node Exporter service
•	Installed at /usr/local/bin/node_exporter
•	Runs using systemd
Backups (cron)
Edit crontab:
crontab -e
Add:
0 2 * * * /opt/blog/scripts/backup_db.sh >> /var/log/backup_db.log 2>&1

**5. Monitoring Setup (Prometheus, Node Exporter, Grafana)**
Prometheus scrapes Node Exporter from EC2 instances. Grafana visualizes metrics.
Node Exporter
•	Installed on App and Jenkins EC2
•	Exposes metrics on 9100
Prometheus Configuration Example
scrape_configs:
  - job_name: "node"
    static_configs:
      - targets:
        - "APP_SERVER_PRIVATE_IP:9100"
        - "JENKINS_SERVER_PRIVATE_IP:9100"
Grafana
•	Add Prometheus as Data Source
•	Import Dashboard (Node Exporter Full Dashboard)

**6. Step-by-Step Implementation**
Includes GitHub setup, Jenkins setup, Docker Hub integration, deployment, backups, and monitoring.

GitHub
•	Create repository
•	Add Webhook:
http://JENKINS_IP:8080/github-webhook/
•	Generate PAT tokens (one for Jenkins checkout)

Jenkins Setup
•	Install Jenkins
•	Install plugins: Git, Pipeline, Docker, SSH Agent
•	Add Credentials:
o	dockerhub-creds
o	app-ssh (EC2 private key)

CI/CD Flow
1.	Developer pushes to GitHub
2.	Webhook triggers Jenkins
3.	Jenkins builds image → pushes to Docker Hub
4.	Jenkins SSH → App Server → deploy.sh
5.	Container runs on port 80
   
**7. Testing & Validation**
 Verifying CI/CD, container deployment, metrics, and backups.
•	docker ps shows container running
•	Blog loads in browser
•	Posts are saved in SQLite
•	Cron backups appear in /opt/blog/backups
•	Prometheus target shows UP
•	Grafana dashboard shows metrics

**Installation Commands** :
Docker: (install on both instances)
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable"

sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker

# Allow current user to run docker without sudo
sudo usermod -aG docker $USER

**Java : Install on Jenkins server**
sudo apt update
sudo apt install -y fontconfig openjdk-17-jre
java -version

**Jenkins: Install on Jenkins server**
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
sudo systemctl status Jenkins
Jenkins UI → http://<EC2-IP>:8080

**Prometheus: Install on App server**
sudo useradd -rs /bin/false Prometheus
cd /opt
wget https://github.com/prometheus/prometheus/releases/download/v2.51.0/prometheus-2.51.0.linux-amd64.tar.gz
tar -xvf prometheus-2.51.0.linux-amd64.tar.gz

sudo mv prometheus-2.51.0.linux-amd64 /etc/prometheus
sudo mkdir -p /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/Prometheus

Create system service
sudo tee /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
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

Start Prometheus
sudo systemctl daemon-reload
sudo systemctl enable --now prometheus
sudo systemctl status Prometheus

Prometheus UI: http://<SERVER-IP>:9090

**Node Exporter: Install on both instances**
Create user
sudo useradd -rs /bin/false node_exporter
Download and install
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.7.0.linux-amd64.tar.gz
sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/

Create systemd service
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

Start Node Exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter

Node Exporter metrics: http://<SERVER-IP>:9100/metrics

**Grafana: Install on App server**
sudo apt update
sudo apt install -y apt-transport-https software-properties-common wget

wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

echo "deb https://packages.grafana.com/oss/deb stable main" \
  | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt update
sudo apt install -y grafana

sudo systemctl daemon-reload
sudo systemctl enable --now grafana-server
sudo systemctl status grafana-server

Grafana UI: http://<SERVER-IP>:3000

Login:
user: admin
pass: admin

**Commands to verify all services:**
**Docker**
docker --version
docker ps
sudo systemctl status docker
docker images
docker start <container_name>
docker logs -f <container_name>

**Jenkins**
systemctl status jenkins

**Prometheus**
systemctl status prometheus
curl http://localhost:9090/targets

**Node Exporter**
systemctl status node_exporter
curl http://localhost:9100/metrics

**Grafana**
systemctl status grafana-server

**Blog-app**
http://<app-server-ip> 
