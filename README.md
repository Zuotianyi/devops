# devops hw 1
1. Run the following command to set up docker image and containers
 ```sh
   chmod +x docker_setup.sh && ./docker_setup.sh
```


<img width="1261" alt="Screenshot 2023-11-07 at 9 00 47 PM" src="https://github.com/Zuotianyi/devops/assets/55261595/0975622b-1293-41bf-8017-607fa233d856">
<img width="1261" alt="Screenshot 2023-11-07 at 9 00 24 PM" src="https://github.com/Zuotianyi/devops/assets/55261595/f33fa604-29d5-4498-a9e6-b3542e40c2e8">
<br>
<br>

2. Manually generate Jenkins API token through dashboard and update it in jenkins_config.sh. Then run the following command to setup Jenkins and Snoarqube

```sh
   chmod +x jenkins_config.sh && ./jenkins_config.sh
```
<br>
After execution, there should be a Jenkins API token, two Jenkins credentials, a Sonarqube token, and a Sonarqube project named petclinic configured.<br>
<img width="1429" alt="Screenshot 2023-11-07 at 10 07 19 PM" src="https://github.com/Zuotianyi/devops/assets/55261595/76ba0382-96c5-44b8-9bd9-9fe5c8d6b49b">
<img width="1439" alt="Screenshot 2023-11-07 at 10 06 53 PM" src="https://github.com/Zuotianyi/devops/assets/55261595/8a8d626d-3e95-4062-939c-08f50f58dbcf">
<img width="1203" alt="Screenshot 2023-11-07 at 10 05 52 PM" src="https://github.com/Zuotianyi/devops/assets/55261595/9cd46cb3-e828-4015-bed1-d61b8090cb54">
<br>
<br>
<br>

3. Login to Sonarqube dashboard at localhost:9000 with username:admin and password:password. 
Navigate to **Administration > Security > Global Permissions** and configure the permissions as below for Jenkins pipeline.
<img width="1425" alt="Screenshot 2023-11-07 at 9 17 43 PM" src="https://github.com/Zuotianyi/devops/assets/55261595/0441ae03-6f03-49e2-a962-c14ef4c9a9fd">

<br>
<br>
<br>

4. Login to Jenkins dashboard with username: admin and the initial Jenkins password. Navigate to **add new items** to create project petclinic_viz and select *Freestyle project*. Configure as below using Git as SCM.
<img width="1026" alt="Screenshot 2023-11-07 at 9 41 52 PM" src="https://github.com/Zuotianyi/devops/assets/55261595/7468c975-2ae4-4bc6-8d64-760460743e18">
<br>
<br>
<br>

5. Navigate to petclinic_viz and select **Build Now**. The results would be as below.
<img width="1440" alt="Screenshot 2023-11-06 at 7 07 48 PM" src="https://github.com/Zuotianyi/devops/assets/55261595/2f018d5b-1bbd-4902-ac35-0fbbed15a5b6">
<br>
<img width="1440" alt="Screenshot 2023-11-06 at 7 06 32 PM" src="https://github.com/Zuotianyi/devops/assets/55261595/a95f663c-622c-47d8-874d-70259d01f455">
<br>
<br>
<br>
6. Access the welcome screen at localhost:8081
<img width="1440" alt="Screenshot 2023-11-06 at 7 06 34 PM" src="https://github.com/Zuotianyi/devops/assets/55261595/8f50b270-1d8a-45cc-9327-5dd72fc49c9c">


   


