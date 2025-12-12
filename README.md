DevOps CI/CD Simple Blog Project Documentation
1. Project Overview
This project demonstrates a complete end-to-end DevOps pipeline including a Flask application, Docker containerization, Jenkins CI/CD, automated deployments, cron-based backups, and monitoring using Prometheus, Node Exporter, and Grafana.
Tech Stack:
Source Control:  Git, GitHub (Code hosting, version control, webhook triggers for CI)
CI/CD Automation: Jenkins on AWS EC2 (Automates build, Docker image creation, push to Docker Hub and deployment)
Application: Python(Flask)(Lightweight web server used to demonstrate deployment pipeline)
Containerization: Docker, Docker Hub Registry (Packages and ships the application as immutable images)
Infrastructure: AWS EC2(ubuntu server) (Runs Jenkins, Application Docker Host, Prometheus and Grafana)
Monitoring: Prometheus+Node Exporter and Grafana (Infrastructure & application performance monitoring and dashboard visualization)
Automation & Scripting: Bash Shell Scripts (Deployment automation, backup scripts, log rotation and cron jobs)
Job Scheduling: Cron(Linux Crontab) (Automated task scheduling for backups and housekeeping)
2. Architecture & Instance Sizing
Architecture Flow:
GitHub (Webhook) → Jenkins EC2 → Docker Hub → App EC2 (Docker Deployment) → Monitoring EC2 (Prometheus + Grafana).
Recommended EC2 Instances:
- Jenkins: t3.micro
- App Server: t3.micro
AMI: Ubuntu 22.04
3. Repository Structure
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
4. Required Files
4.1 Flask Application – app/app.py
from flask import Flask, request, render_template, redirect, url_for
import sqlite3
import os

DB_PATH = os.environ.get('DB_PATH', 'blog.db')
app = Flask(__name__)

def get_conn():
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn

conn = get_conn()
conn.execute('''CREATE TABLE IF NOT EXISTS posts (id INTEGER PRIMARY KEY, title TEXT, body TEXT)''')
conn.commit()

@app.route('/')
def index():
    cur = conn.execute('SELECT * FROM posts ORDER BY id DESC')
    posts = cur.fetchall()
    return render_template('index.html', posts=posts)

@app.route('/post', methods=['POST'])
def post():
    title = request.form.get('title')
    body = request.form.get('body')
    conn.execute('INSERT INTO posts (title, body) VALUES (?, ?)', (title, body))
    conn.commit()
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

4.2 HTML Template – app/templates/index.html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Simple Blog Demo Project</title>
  <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
  <main class="page">
    <div class="card">
      <header class="card-header">
        <h1>Simple Blog</h1>
        <p class="subtitle">Write quick posts — <span class="hint">no login required</span></p>
      </header>

      <section class="composer">
        <form action="/post" method="post" class="post-form">
          <input name="title" class="input title" placeholder="Title" required/>
          <textarea name="body" class="input body" placeholder="Write your post here..." required></textarea>
          <div class="controls">
            <button type="submit" class="btn">Publish</button>
          </div>
        </form>
      </section>

      <hr class="divider" />

      <section class="posts">
        {% for p in posts %}
          <article class="post">
            <h3 class="post-title">{{ p.title }}</h3>
            <p class="post-body">{{ p.body }}</p>
          </article>
        {% else %}
          <p class="no-posts">No posts yet — be the first!</p>
        {% endfor %}
      </section>

      <footer class="card-footer">
        <small>Made with ❤️ — DevOps Demo</small>
      </footer>
    </div>
  </main>
</body>
</html>
4.3 app/static/style.css:
/* Full-page layout + background */
:root{
  --card-bg: rgba(255,255,255,0.92);
  --muted: #666;
  --accent: #3b82f6;
}

*{box-sizing:border-box}
html,body{height:100%;margin:0;font-family:Inter,system-ui,-apple-system,Segoe UI,Roboto,"Helvetica Neue",Arial}
body{
  /* Option A: gradient background (fast, no image) */
  background: linear-gradient(120deg, #0f172a 0%, #1e293b 40%, #0ea5a4 100%);
  color:#0b1220;
  -webkit-font-smoothing:antialiased;
  -moz-osx-font-smoothing:grayscale;
  padding:24px;
  overflow-y:auto;
}

/* Option B: image background
body{
  background: url('/static/bg.jpg') center/cover no-repeat fixed;
}
*/

/* Card */
.page{width:100%;max-width:980px;margin:0 auto;}
.card{
  background: var(--card-bg);
  border-radius:14px;
  box-shadow: 0 10px 30px rgba(2,6,23,0.45);
  overflow:hidden;
  padding:28px;
  width:100%;
}

/* Header */
.card-header{margin-bottom:8px}
.card-header h1{margin:0;font-size:28px;color:#0f172a}
.subtitle{margin:6px 0 0;color:var(--muted);font-size:13px}
.hint{color:var(--accent);font-weight:600}

/* Composer */
.composer{margin-top:12px}
.post-form{display:flex;flex-direction:column;gap:10px}
.input{width:100%;padding:10px;border-radius:8px;border:1px solid #e6eef9;background:#fff;font-size:14px}
.input.title{height:44px}
.input.body{min-height:110px;resize:vertical;padding:12px}
.controls{display:flex;justify-content:flex-end}
.btn{
  background: linear-gradient(90deg,var(--accent),#2563eb);
  color:white;border:none;padding:10px 16px;border-radius:10px;font-weight:600;cursor:pointer;box-shadow:0 6px 18px rgba(14,165,164,0.12)
}
.btn:hover{transform:translateY(-1px);transition:all .12s ease}

/* Posts */
.divider{border:0;border-top:1px solid #eef3ff;margin:18px 0}
.post{padding:10px 0;border-bottom:1px dashed rgba(15,23,42,0.04)}
.post-title{margin:0 0 6px;font-size:18px;color:#0f172a}
.post-body{margin:0;color:#0b1220;line-height:1.5}
.no-posts{color:var(--muted);padding:6px 0}

/* Footer */
.card-footer{margin-top:14px;color:var(--muted);font-size:13px;text-align:center}

/* Mobile tweaks */
@media (max-width:600px){
  .card{padding:18px;border-radius:10px}
  .card-header h1{font-size:22px}
}
4.3 Requirements File – app/requirements.txt
Flask==2.2.5
4.4 Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY app/ ./app/
RUN pip install --no-cache-dir -r app/requirements.txt
ENV FLASK_APP=app/app.py
ENV DB_PATH=/data/blog.db
RUN mkdir -p /data
EXPOSE 5000
CMD ["python","app/app.py"]
4.5 docker-compose.yml
version: '3.8'
services:
  blog:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - ./data:/data
4.6 Deployment Script – scripts/deploy.sh
#!/bin/bash
set -e

APP_NAME=blog
IMAGE=$1
CONTAINER_NAME=${APP_NAME}-container

docker pull ${IMAGE}

if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
  docker stop ${CONTAINER_NAME}
  docker rm ${CONTAINER_NAME}
fi

docker run -d --name ${CONTAINER_NAME} -p 80:5000   -v /opt/${APP_NAME}/data:/data   --restart=always   ${IMAGE}
4.7 Backup Script – scripts/backup_db.sh
#!/bin/bash
set -e

BACKUP_DIR=/opt/blog/backups
DATA_DIR=/opt/blog/data
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

mkdir -p ${BACKUP_DIR}

cp ${DATA_DIR}/blog.db ${BACKUP_DIR}/blog-${TIMESTAMP}.db

ls -1tr ${BACKUP_DIR}/blog-*.db | head -n -7 | xargs -r rm -f
4.8 Jenkinsfile
pipeline {
  agent any
  environment {
    DOCKER_IMAGE = "yourdockerhubuser/blog:${env.BUILD_NUMBER}"
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build') {
      steps { sh 'docker build -t ${DOCKER_IMAGE} .' }
    }
    stage('Test') {
      steps { echo 'No unit tests configured.' }
    }
    stage('Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
         usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PWD')]) {
          sh 'echo $DOCKERHUB_PWD | docker login -u $DOCKERHUB_USER --password-stdin'
          sh 'docker push ${DOCKER_IMAGE}'
        }
      }
    }
    stage('Deploy') {
      steps {
        script {
          def servers = ["ubuntu@app-server-ip"]
          for (s in servers) {
            sshagent(['app-ssh']) {
              sh "ssh -o StrictHostKeyChecking=no ${s} 'mkdir -p /opt/blog/data /opt/blog/scripts'"
              sh "scp -o StrictHostKeyChecking=no scripts/deploy.sh ${s}:/opt/blog/scripts/deploy.sh"
              sh "ssh ${s} 'chmod +x /opt/blog/scripts/deploy.sh && /opt/blog/scripts/deploy.sh ${DOCKER_IMAGE}'"
            }
          }
        }
      }
    }
  }
}
5. Systemd and Cron Notes
Node Exporter and Prometheus run as systemd services. Cron runs backups daily.
Node Exporter service
•	Installed at /usr/local/bin/node_exporter
•	Runs using systemd
Backups (cron)
Edit crontab:
crontab -e
Add:
0 2 * * * /opt/blog/scripts/backup_db.sh >> /var/log/backup_db.log 2>&1
6. Monitoring Setup (Prometheus, Node Exporter, Grafana)
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
7. Step-by-Step Implementation
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
8. Testing & Validation
 Verifying CI/CD, container deployment, metrics, and backups.
•	docker ps shows container running
•	Blog loads in browser
•	Posts are saved in SQLite
•	Cron backups appear in /opt/blog/backups
•	Prometheus target shows UP
•	Grafana dashboard shows metrics

Installation Commands :
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

Java : Install on Jenkins server
sudo apt update
sudo apt install -y fontconfig openjdk-17-jre
java -version

Jenkins: Install on Jenkins server
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

Prometheus: Install on App server
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

Node Exporter: Install on both instances
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

Grafana: Install on App server
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

Commands to verify all services:
Docker
docker --version
docker ps
sudo systemctl status docker
docker images
docker start <container_name>
docker logs -f <container_name>
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
