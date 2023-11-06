pipeline {
    agent any
    tools {
        maven 'M3'
        jdk 'jdk17'
    }
    environment {
        SONARQUBE_TOKEN = credentials('sonarqube-token')
        CREDENTIALS = credentials('jenkins-credentials-id')
    }
    stages {
        stage('Checkout') {
            steps {
                // Checkout the source code
                git branch: 'main', url: 'https://github.com/spring-projects/spring-petclinic.git'
            }
        }
        stage('Build and Test') {
            steps {
                // Run Maven to compile, test, and package the application.
                sh 'mvn clean package -Dmaven.test.failure.ignore=true'
            }
            post {
                // Always record the test results and archive the jar file, even if the Maven build failed.
                always {
                    junit '**/target/surefire-reports/TEST-*.xml'
                    archiveArtifacts 'target/*.jar'
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                // Perform SonarQube analysis
                withSonarQubeEnv('sonar') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=petclinic -Dsonar.login=$SONARQUBE_TOKEN'
                }
            }
        }
        stage('Download Artifact') {
            steps {
                script {
                    // Define the artifact URL
                    def artifactUrl = "http://localhost:8080/job/petclinic_viz/lastSuccessfulBuild/artifact/target/spring-petclinic-3.1.0-SNAPSHOT.jar"
                    // Use curl with Jenkins credentials to download the artifact
                    withCredentials([usernamePassword(credentialsId: 'jenkins-credentials-id', usernameVariable: 'JENKINS_USER', passwordVariable: 'JENKINS_PASSWORD')]) {
                        sh "curl -u $JENKINS_USER:$JENKINS_PASSWORD -o spring-petclinic-3.1.0-SNAPSHOT.jar ${artifactUrl}"
                    }
                }
            }
        }
        stage('Execute Jar') {
            steps {
                // Execute the Spring Boot application on port 8081
                sh 'nohup java -jar target/petclinic.jar --server.port=8081 &'
            }
        }
    }
}
