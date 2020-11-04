#!/bin/bash -x
set -e

# 8/28/20 - Delete this comment block if k8s deployment.yaml dnsconfig is still functioning properly in a few weeks
# Adding DNS logic to support CA-based deployments 
#grep 10.100 /etc/resolv.conf
## grep result exits container
#if [ $? = 1 ] ; then echo "nameserver 10.100.211.10 10.2.249.11" >> /etc/resolv.conf; fi
## can't have 2 nameserver entries per line? also nameserver is a replace vs add a secondary
#cp /etc/resolv.conf /etc/resolv.update
#sed -i '/nameserver/c\nameserver 10.100.211.10' /etc/resolv.update
#cp /etc/resolv.update /etc/resolv.conf

export deploymentLabel=idp
export AGENT_ALLOW_RUNASROOT="1"
export AZP_URL=https://dev.azure.com/rms-cicd-pipeline
AZP_TOKEN=$(aws ssm get-parameters --with-decryption --names /idp-config/global/AzDO/idp-token --query "Parameters[*].{Value:Value}" --output text)

cd agent

./config.sh --url $AZP_URL --auth pat --token $AZP_TOKEN --agent idp-ca-microk8s-$HOSTNAME --acceptTeeEula --pool CA-OnPrem-Agents --work _work & wait

unset AZP_TOKEN

./run.sh
