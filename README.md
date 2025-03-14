# infrastructure-examples

This repository contains various infrastructure examples, each including a `jenkins-agent.Dockerfile` for setting up a Jenkins agent to build and deploy the corresponding project.

## How to Deploy

1. Clone the repository:

2. Modify the `docker-compose.yml` file to point the `jenkins-agent` container to the appropriate project and its `jenkins-agent.Dockerfile`. For example:
   ```yaml
   jenkins-agent:
     build:
       context: .
       dockerfile: aws/storage/efs-ec2-simple/jenkins-agent.Dockerfile
   ```

3. Start the Jenkins environment using Docker Compose:
   ```sh
   docker-compose up -d
   ```

   This will spin up two containers:
   - `jenkins-controller`: The main Jenkins server.
   - `jenkins-agent`: A Jenkins agent configured for the specified project.

4. Access the Jenkins UI:
   - Open a browser and go to `http://localhost:8081`
   - Retrieve the initial admin password from the controller container:
     ```sh
     docker exec jenkins-controller cat /var/jenkins_home/secrets/initialAdminPassword
     ```
   - Follow the Jenkins setup wizard to complete the installation.

5. Configure your Jenkins agent in Jenkins:
   - Navigate to **Manage Jenkins** -> **Manage Nodes and Clouds**.
   - Verify that the `jenkins-agent` is connected.
   - Set up your pipeline and jobs as needed pointing to the jenkins files inside each example.

6. For initial setup you'll have to create the agent yourself.
   - Navigate to **Manage Jenkins** -> **Nodes**  -> **New Node**
   - In **remote root directory** type /home/jenkins/agent
   - **Launch method** select **Launch agents via SSH**
   - **Host** is **jenkins-agent**
   - **Credentials** create a new credential of type SSH username with private key. Username is **jenkins** and the private key you should see it in the logs of the jenkins-agent container. It's logged everytime the container is started

7. each example container a Jenkins-destroy file. don't forget to destroy not needed resources