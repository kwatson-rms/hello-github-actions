# Defining standardized container ARG structure
# The transition plan is to use the RMS BASE_REGISTRY hardened image registry
ARG BASE_REGISTRY=mcr.microsoft.com
ARG BASE_IMAGE=powershell
ARG BASE_TAG=ubuntu-18.04


# FROM statement must reference the base image using the three ARGs established
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get clean && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    git \
    jq \
    gnupg \
    python-pip \
    unzip \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Install git-lfs
RUN  curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
     apt-get update && \
     apt-get install -y --no-install-recommends \
        git-lfs && \
    rm -rf /var/lib/apt/lists/*

# Install Docker Client
ENV DOCKERVERSION=19.03.9
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
  && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
                 -C /usr/local/bin docker/docker \
  && rm docker-${DOCKERVERSION}.tgz

# Install azure devops agent
ENV VSTS_VERSION=2.172.2
RUN mkdir -p /opt/azp/agent && \
    curl -o vsts-agent-linux-x64-${VSTS_VERSION}.tar.gz https://vstsagentpackage.azureedge.net/agent/${VSTS_VERSION}/vsts-agent-linux-x64-${VSTS_VERSION}.tar.gz && \
    tar -C /opt/azp/agent -xf vsts-agent-linux-x64-${VSTS_VERSION}.tar.gz && \
    rm vsts-agent-linux-x64-${VSTS_VERSION}.tar.gz

# Install jfrog cli
ENV JFROG_CLI_OFFER_CONFIG false
ENV JFROG_CLI_LOG_LEVEL DEBUG
RUN mkdir /usr/share/jfrog && \
    curl -XGET "https://bintray.com/jfrog/jfrog-cli-go/download_file?file_path=1.28.0%2Fjfrog-cli-linux-amd64%2Fjfrog" -L -k > /usr/share/jfrog/jfrog && \
    chmod u+x /usr/share/jfrog/jfrog && \
    ln -sf /usr/share/jfrog/jfrog /usr/bin/jfrog

#RUN wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb && \ 
#    dpkg -i packages-microsoft-prod.deb

# Install packer
ENV PACKER_VERSION=1.6.1
RUN curl -so packer_${PACKER_VERSION}.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}.zip && \
    mv packer /usr/local/bin/ && \
    rm packer_${PACKER_VERSION}.zip

# Install terraform
ENV TERRAFORM_VERSION=0.12.29
RUN curl -so terraform_${TERRAFORM_VERSION}.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}.zip

# Install AWS CLI v2
RUN curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip -q awscliv2.zip && \
    aws/install && \
    rm -rf awscliv2.zip

# Install Python packages: pytenable, requests 
RUN python -m pip install -U pip setuptools && \
    python -m pip install -qqq \
            requests

# pytenabe 1.2+ doesn't support marshmallow on python2
RUN python -m pip install -I pytenable==1.1.4

# Packer Update Provisioner
RUN wget -q https://github.com/rgl/packer-provisioner-windows-update/releases/download/v0.9.0/packer-provisioner-windows-update-linux.tgz && \
    tar -zxvf packer-provisioner-windows-update-linux.tgz && \
    chmod +x packer-provisioner-windows-update && \
    mv packer-provisioner-windows-update /usr/local/bin && \
    rm -rf packer-provisioner-windows-update-linux.tgz

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Packer Build Opts
ENV AWS_POLL_DELAY_SECONDS=20 AWS_MAX_ATTEMPTS=300 PACKER_LOG_PATH="packer.log" PACKER_LOG=1

# Set AzDO Agent dir
WORKDIR /opt/azp

#COPY start.sh .

HEALTHCHECK --timeout=15s CMD packer --version && terraform --version && aws --version

#CMD exec "./start.sh"
