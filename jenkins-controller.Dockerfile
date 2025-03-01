FROM jenkins/jenkins:lts-jdk17

USER root

RUN apt-get update && apt-get install -y netcat-openbsd && rm -rf /var/lib/apt/lists/*

COPY ./jenkins-controller-entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh && chown jenkins:jenkins /usr/local/bin/entrypoint.sh

USER jenkins

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
