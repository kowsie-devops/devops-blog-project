pipeline {
agent any
environment {
DOCKER_IMAGE = "kowsie/blog-app:${env.BUILD_NUMBER}"
}
stages {
stage('Checkout') {
steps { checkout scm }
}
stage('Build') {
steps {
sh 'docker --version'
sh 'docker build -t ${DOCKER_IMAGE} .'
}
}
stage('Test') {
steps {
// add tests here if you have any
echo 'No unit tests configured.'
}
}
stage('Push') {
steps {
withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PWD')]) {
sh 'echo $DOCKERHUB_PWD | docker login -u $DOCKERHUB_USER --password-stdin'
sh 'docker push ${DOCKER_IMAGE}'
}
}
}
stage('Deploy') {
steps {
// SSH to the app servers and run deploy script
// configure SSH credentials in Jenkins (id: 'app-ssh')
script {
def servers = ["ubuntu@15.206.148.173"]
for (s in servers) {
sshagent(['app-ssh']) {
sh "ssh -o StrictHostKeyChecking=no ${s} 'sudo mkdir -p /opt/blog/data /opt/blog/scripts'"
// copy deploy script
sh "scp -o StrictHostKeyChecking=no scripts/deploy.sh ${s}:/tmp/deploy.sh"
sh 'ssh -o StrictHostKeyChecking=no ' + s + ' "sudo mv /tmp/deploy.sh /opt/blog/scripts/deploy.sh && sudo chmod +x /opt/blog/scripts/deploy.sh && sudo /opt/blog/scripts/deploy.sh ' + DOCKER_IMAGE + '"'
}
}
}
}
}
}
post {
always {
echo 'Cleanup if needed'
}
success {
echo 'Deployment succeeded.'
}
}
}
