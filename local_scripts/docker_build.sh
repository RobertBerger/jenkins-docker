#!/bin/bash
source ../container-name.sh

if [ $# -lt 1 ];
then
    echo "+ $0: Too few arguments!"
    echo "+ use something like:"
    echo "+ $0 <CONTAINER_NAME>"
    echo "+ $0 ${CONTAINER_NAME}"
    exit
fi

if [ ! -d ../usr/share/jenkis ]; then
   mkdir -p ../usr/share/jenkins
fi

pushd ../usr/share/jenkins
# let's get the checksum
rm -f jenkins.war.sha256
wget http://mirrors.jenkins.io/war-stable/${JENKINS_WAR_VERSION}/jenkins.war.sha256

if [ -f jenkins.war ]; then
   echo "+ jenkins.war already exists - calculating the checksum"
   echo "$(cat jenkins.war.sha256)" | sha256sum --check --status
   if [ $? -eq 1 ]; then
      echo "+ rm -f jenkins.war"
      rm -f jenkins.war
      echo "+ checksum error - downloading  http://mirrors.jenkins.io/war-stable/${JENKINS_WAR_VERSION}/jenkins.war"
      echo "+ wget http://mirrors.jenkins.io/war-stable/${JENKINS_WAR_VERSION}/jenkins.war"
      wget http://mirrors.jenkins.io/war-stable/${JENKINS_WAR_VERSION}/jenkins.war
   fi
else
   echo "+ downloading  http://mirrors.jenkins.io/war-stable/${JENKINS_WAR_VERSION}/jenkins.war"
   echo "+ wget http://mirrors.jenkins.io/war-stable/${JENKINS_WAR_VERSION}/jenkins.war"
   wget http://mirrors.jenkins.io/war-stable/${JENKINS_WAR_VERSION}/jenkins.war
fi

echo "$(cat jenkins.war.sha256)" | sha256sum --check --status
if [ $? -eq 1 ]; then
   echo "+ fatal checksum error"
   exit 1
else
   echo "+ checksum is OK"
fi

popd

pushd ..
set -x
#docker build --no-cache --rm=true -t reslocal/${CONTAINER_NAME} .
docker build --rm=true -t reslocal/${CONTAINER_NAME} .
set +x
popd

while true; do
    read -p "Do you wish to kill the .war file and the sha256 checksum - for version control?" yn
    case $yn in
        [Yy]* ) rm -f ../usr/share/jenkins/*; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

