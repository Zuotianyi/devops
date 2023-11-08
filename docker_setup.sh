 #!/bin/bash

# Set up Jenkins with SonarQube and Blue Ocean plugins
setup_jenkins() {
  echo "Building Jenkins image with required plugins..."
  # the Dockerfile and plugins.txt are in the current directory
  docker build -t myjenkins-blueocean-sonarqube:1.1 .
}

# Pull SonarQube image
pull_sonarqube() {
  echo "Pulling SonarQube image..."
  docker pull sonarqube
}

# Run Jenkins container
run_jenkins_container() {
  echo "Running Jenkins container..."
  docker run --name jenkins-blue-sonar --rm --detach \
    --publish 8080:8080 --publish 8081:8081 --publish 50000:50000 \
    --volume jenkins-data:/var/jenkins_home \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    myjenkins-blueocean-sonarqube:1.1
}

# Run SonarQube container
run_sonarqube_container() {
  echo "Running SonarQube container..."
  docker run -d --name sonarqube -p 9000:9000 sonarqube
}

setup_jenkins
pull_sonarqube
run_jenkins_container
run_sonarqube_container