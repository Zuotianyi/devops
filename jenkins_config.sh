# Set up environment variables
setup_environment_vars() {
  echo "Setting up environment variables..."
  export JENKINS_CONTAINER_NAME="jenkins-blue-sonar"
  export JENKINS_PASSWORD=$(docker exec "$JENKINS_CONTAINER_NAME" cat /var/jenkins_home/secrets/initialAdminPassword)
  export SONARQUBE_URL="http://localhost:9000"
  export SONARQUBE_USERNAME="admin"
  export SONARQUBE_PASSWORD="password"
  export JENKINS_URL="http://localhost:8080"
  export JENKINS_USERNAME="admin"
  export SONARQUBE_INSTANCE_NAME="sonarqube"
  export JOB_NAME="PetClinicBuild"
}

# Initialize Sonarqube password/remove forced authentication/set permission to anyone
create_sonarqube_password () {
  echo "create sonarqube password"
  #Reset sonarqube Password
  curl -s -vu $SONARQUBE_USERNAME:admin -o /dev/null -X POST "$SONARQUBE_URL/api/users/change_password?login=$SONARQUBE_USERNAME&previousPassword=admin&password=$SONARQUBE_PASSWORD"
}

# Create SonarQube user token
create_sonarqube_user_token() {
  echo "create sonarqube token"
  SONARQUBE_TOKEN=$(curl -s -u "$SONARQUBE_USERNAME:$SONARQUBE_PASSWORD" -X POST "$SONARQUBE_URL/api/user_tokens/generate" \
    -d "name=JenkinsTokenForSonarQube" \
    -d "login=admin" \
    -d "type=GLOBAL_ANALYSIS_TOKEN")
  SONARQUBE_TOKEN=$(echo "$SONARQUBE_TOKEN" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
}

# Create Jenkins API tokens
create_jenkins_api_token () {
  echo "Creating Jenkins API token..."
  JENKINS_CRUMB=$(curl -s "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)" -u "$JENKINS_USERNAME:$JENKINS_PASSWORD")
  response=$(curl -s -X POST -u "$JENKINS_USERNAME:$JENKINS_PASSWORD" \
    -H "$JENKINS_CRUMB" \
    "$JENKINS_URL/user/$JENKINS_USERNAME/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" \
    --data-urlencode "newTokenName=ScriptToken" \
    --data-urlencode "newTokenDescription=API Token for scripts" \
    --data-urlencode "newTokenTTL=365")
  JENKINS_TOKEN=$(echo "$response" | jq -r '.data.tokenValue')
  echo "Jenkins API token created: $JENKINS_TOKEN"
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

# create Jenkins credentials for downloading jar file
create_jenkins_username_password_credential () {
  echo "Creating Jenkins credentials id..."
  local credential_id="jenkins-credentials-id"

  curl -X POST -u "$JENKINS_USERNAME:$JENKINS_TOKEN" "$JENKINS_URL/credentials/store/system/domain/_/createCredentials" \
  --data-urlencode "json={
    '': '0',
    'credentials': {
      'scope': 'GLOBAL',
      'id': '$credential_id',
      'username': 'admin',
      'password': 'password',
      'description': 'Jenkins Admin User',
      'stapler-class': 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl',
      '\$class': 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl'
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

echo "Setting up Sonarqube/Jenkins credentials"
setup_environment_vars
create_sonarqube_password
create_sonarqube_user_token
create_jenkins_sonar_credential
create_jenkins_sonar_credential
create_jenkins_username_password_credential
echo "Create Petclinic project on Sonarqube"
create_petclinic_project_sq
echo "Create Petclinic project on Jenkins"
create_petclinic_project_jk
