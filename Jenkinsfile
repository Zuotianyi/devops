pipeline {
    agent any
    tools {
        maven 'M3'
    }
    environment {
        SONARQUBE_TOKEN = credentials('sonarqube-token')
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
        stage('Execute Jar') {
            steps {
                sh 'nohup java -jar  spring-petclinic-3.1.0-SNAPSHOT.jar --server.port=8081 &'
            }
        }
    }
}
