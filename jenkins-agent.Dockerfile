# Stage 1: Install Terraform on a Debian-based image
FROM debian:bookworm AS terraform-installer

RUN apt update && apt install -y wget gpg lsb-release

RUN wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

RUN apt update && apt install -y terraform

# Stage 2: Final Jenkins agent image
FROM jenkins/ssh-agent:latest-jdk21

# Copy Terraform binary from the first stage
COPY --from=terraform-installer /usr/bin/terraform /usr/bin/terraform

# Verify installation
RUN terraform --version
