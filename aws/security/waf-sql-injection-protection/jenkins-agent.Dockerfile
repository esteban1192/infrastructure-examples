FROM debian:bookworm AS terraform-installer

RUN apt update && apt install -y wget gpg lsb-release unzip curl

ARG TERRAFORM_VERSION=1.11.0
RUN wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -O terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/bin/terraform && \
    chmod +x /usr/bin/terraform

FROM jenkins/ssh-agent:latest-jdk21

COPY --from=terraform-installer /usr/bin/unzip /usr/bin/unzip
COPY --from=terraform-installer /usr/bin/terraform /usr/bin/terraform

RUN apt update && apt install -y curl

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

COPY aws/storage/efs-ec2-simple/jenkins-agent-entrypoint.sh /home/jenkins/entrypoint.sh

RUN chmod +x /home/jenkins/entrypoint.sh

ENV AUTHORIZED_KEYS="/home/jenkins/.ssh/authorized_keys"
RUN mkdir -p /home/jenkins/.ssh && \
    touch "$AUTHORIZED_KEYS" && \
    chmod 600 "$AUTHORIZED_KEYS" && \
    chown -R jenkins:jenkins /home/jenkins/.ssh && \
    chmod 700 /home/jenkins/.ssh

ENTRYPOINT ["/home/jenkins/entrypoint.sh"]
