# Set up environment variables
setup_environment_vars() {
  echo "Setting up environment variables..."
  export JENKINS_CONTAINER_NAME="jenkins-blue-sonar"
  export JENKINS_PASSWORD=$(docker exec "$JENKINS_CONTAINER_NAME" cat /var/jenkins_home/secrets/initialAdminPassword)
  export SONARQUBE_URL="http://localhost:9000"
  export SONARQUBE_USERNAME="admin"
  export SONARQUBE_PASSWORD="password" # Change this to the actual desired password
  export JENKINS_URL="http://localhost:8080"
  export JENKINS_USERNAME="admin"
  export SONARQUBE_INSTANCE_NAME="sonarqube"
  export JOB_NAME="PetClinicBuild"
  export JENKINS_TOKEN="11553ec164e158aa0f964110f7a8341c67" #create jenkins token through dashboard
}

#success
# Initialize Sonarqube password/remove forced authentication/set permission to anyone
create_sonarqube_password () {
  echo "create sonarqube password"
  #Reset sonarqube Password
  curl -s -vu $SONARQUBE_USERNAME:admin -o /dev/null -X POST "$SONARQUBE_URL/api/users/change_password?login=$SONARQUBE_USERNAME&previousPassword=admin&password=$SONARQUBE_PASSWORD"
}

#success
# create SonarQube user token
create_sonarqube_user_token() {
  echo "create sonarqube token"
  SONARQUBE_TOKEN=$(curl -s -u "$SONARQUBE_USERNAME:$SONARQUBE_PASSWORD" -X POST "$SONARQUBE_URL/api/user_tokens/generate" \
    -d "name=JenkinsTokenForSonarQube" \
    -d "login=admin" \
    -d "type=GLOBAL_ANALYSIS_TOKEN")
  SONARQUBE_TOKEN=$(echo "$SONARQUBE_TOKEN" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
}

# create Jenkins secret text credential for sonarqube plugin
create_jenkins_sonar_credential () {
  echo "create credential for sonarqube plugin"
  local credential_id="sonarqube-token"
  local credential_description="SonarQube User Token"

  curl -X POST -u "$JENKINS_USERNAME:$JENKINS_TOKEN" "$JENKINS_URL/credentials/store/system/domain/_/createCredentials" \
  --data-urlencode "json={
    '': '0',
    'credentials': {
      'scope': 'GLOBAL',
      'id': '$credential_id',
      'secret': '$SONARQUBE_TOKEN',
      'description': '$credential_description',
      'stapler-class': 'org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl',
      '\$class': 'org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl'
    }
  }"
}

# Function to create Petclinic project in Sonarqube
create_petclinic_project_sq() {
  curl -s -u "$SONARQUBE_USERNAME:$SONARQUBE_PASSWORD" -o /dev/null -X POST "http://localhost:9000/api/projects/create" \
    -d "project"="petclinic" \
    -d "name"="petclinic" \
    -d "projectVisibility"="public"
}

# Function to create Petclinic job in Jenkins
create_petclinic_project_jk() {
# Jenkins job configuration in XML format
JOB_CONFIG=$(cat << 'EOF'
<flow-definition plugin="workflow-job@2.40">
    <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.85">
        <script>
            <![CDATA[
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
                              withSonarQubeEnv('sonarqube') {
                                  sh "mv{tool 'M3'}/bin/mvn sonar:sonar -Dsonar.projectKey=petclinic -Dsonar.login=${SONARQUBE_TOKEN}"
                              }
                          }
                      }
                      stage('Download Artifact') {
                          steps {
                              script {
                                  // Define the artifact URL
                                  def artifactUrl = "http://localhost:8080/job/PetClinicBuild/lastSuccessfulBuild/artifact/target/spring-petclinic-3.1.0-SNAPSHOT.jar"
                                  // Use curl with Jenkins credentials to download the artifact
                                  sh "curl -u $JENKINS_USERNAME:$JENKINS_TOKEN -o spring-petclinic-3.1.0-SNAPSHOT.jar ${artifactUrl}"
                              }
                          }
                      }
                      stage('Execute Jar') {
                          steps {
                              // Execute the Spring Boot application on port 8081
                              sh 'java -jar spring-petclinic-3.1.0-SNAPSHOT.jar --server.port=8081'
                          }
                      }
                  }
                }
            ]]>
        </script>
        <sandbox>true</sandbox>
    </definition>
</flow-definition>
EOF
)

  # Submit the job configuration to Jenkins using curl
  curl -X POST -u "$JENKINS_USERNAME:$JENKINS_TOKEN" "$JENKINS_URL/createItem?name=$JOB_NAME" --data-binary "$JOB_CONFIG" -H "Content-Type:text/xml"
}

# Function to trigger the Jenkins job
trigger_jenkins_job() {
  curl -o /dev/null -X POST -s -u "$JENKINS_USERNAME:$JENKINS_TOKEN" "$JENKINS_URL/job/$JOB_NAME/build"
}

echo "Setting up Sonarqube/Jenkins credentials"
setup_environment_vars
create_sonarqube_password
create_sonarqube_user_token
create_jenkins_sonar_credential
echo "Create Petclinic project on Sonarqube"
create_petclinic_project_sq
echo "Create Petclinic project on Jenkins"
create_petclinic_project_jk
echo "Starting PetClinicBuild"
trigger_jenkins_job

