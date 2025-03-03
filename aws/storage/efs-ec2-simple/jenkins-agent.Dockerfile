# Stage 1: Install Terraform on a Debian-based image
FROM debian:bookworm AS terraform-installer

RUN apt update && apt install -y wget gpg lsb-release

RUN wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

RUN apt update && apt install -y terraform

FROM jenkins/ssh-agent:latest-jdk21

COPY --from=terraform-installer /usr/bin/terraform /usr/bin/terraform

COPY aws/storage/efs-ec2-simple/jenkins-agent-entrypoint.sh /home/jenkins/entrypoint.sh

RUN chmod +x /home/jenkins/entrypoint.sh

ENTRYPOINT ["/home/jenkins/entrypoint.sh"]
