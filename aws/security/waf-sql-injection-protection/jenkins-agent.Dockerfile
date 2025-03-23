# Stage 1: Install Terraform and AWS CLI on a Debian-based image
FROM debian:bookworm AS terraform-installer

RUN apt update && apt install -y wget gpg lsb-release unzip

RUN wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

RUN apt update && apt install -y terraform

RUN wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "/tmp/awscliv2.zip" \
    && unzip /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install

FROM jenkins/ssh-agent:latest-jdk21

COPY --from=terraform-installer /usr/bin/terraform /usr/bin/terraform
COPY --from=terraform-installer /usr/local/bin/aws /usr/local/bin/aws

COPY aws/storage/efs-ec2-simple/jenkins-agent-entrypoint.sh /home/jenkins/entrypoint.sh

RUN chmod +x /home/jenkins/entrypoint.sh

ENV AUTHORIZED_KEYS="/home/jenkins/.ssh/authorized_keys"
RUN mkdir -p /home/jenkins/.ssh && \
    touch "$AUTHORIZED_KEYS" && \
    chmod 600 "$AUTHORIZED_KEYS" && \
    chown -R jenkins:jenkins /home/jenkins/.ssh && \
    chmod 700 /home/jenkins/.ssh

ENTRYPOINT ["/home/jenkins/entrypoint.sh"]
