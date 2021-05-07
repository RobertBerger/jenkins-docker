[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)


# jenkins-docker
Jenkins in a Docker container, with Docker inside.

There is a blog post associated with this repository, with more information: [Quickstart CI with Jenkins and Docker-in-Docker](https://medium.com/swlh/quickstart-ci-with-jenkins-and-docker-in-docker-c3f7174ee9ff?source=friends_link&sk=e2038207f7049c9000acc56e86b0442e)

Running Jenkins in Docker makes a lot of sense: its super quick to get going, and you can just expose the ports needed to access via the web interface. But it also makes sense to run your test cases/builds inside Docker as well: its compartmentalised, with full control of the environment inside.

This Dockerfile just takes the current, official Jenkins long term support (LTS) Docker image, installs Docker CE inside, and adds the `jenkins` user to the `docker` group.

[It is recommended](https://github.com/jenkinsci/docker/blob/master/README.md) to create an explicit volume on the host machine, that will survive the container stop/restart/deletion. Use this argument when you run Docker: `-v jenkins_home:/var/jenkins_home`

### Docker in Docker
Its possible to run into some problems with Docker running inside another Docker container ([more info here](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)). A better approach is that a container does not run its own Docker daemon, but connects to the Docker daemon of the host system. That means, you will have a Docker CLI in the container, as well as on the host system, but they both connect to one and the same Docker daemon. At any time, there is only one Docker daemon running in your machine, the one running on the host system. This [article from Daniel Weibel](https://itnext.io/docker-in-docker-521958d34efd) really helped me understand this. To do this, you just bind mount to the host system daemon, using this argument when you run Docker: `-v /var/run/docker.sock:/var/run/docker.sock`

### Running the container
The easiest way is to pull from Docker Hub:

    docker run -it -p 8080:8080 -p 50000:50000 \
	    -v jenkins_home:/var/jenkins_home \
	    -v /var/run/docker.sock:/var/run/docker.sock \
	    --restart unless-stopped \
	    4oh4/jenkins-docker

Alternatively, you can clone this repository, build the image from the Dockerfile, and then run the container

    docker build -t jenkins-docker .

    docker run -it -p 8080:8080 -p 50000:50000 \
	    -v jenkins_home:/var/jenkins_home \
	    -v /var/run/docker.sock:/var/run/docker.sock \
	    --restart unless-stopped \
	    jenkins-docker

### Plugin updates

You can just update them via the web gui - persistant

### jenkins.war update

Added it to dockerfile

### install on new machine - move old data

*) let jenkins start once and log in

*) on master

sudo bash

cd /var/lib/docker/volumes/jenkins_home/_data

tar czvf jobs.tar.gz jobs

scp jobs.tar.gz <user>@<ip>:/tmp

scp config.xml <user>@<ip>:/tmp

*) on other machine

sudo bash

cd /var/lib/docker/volumes/jenkins_home/_data

tar xvf /tmp/jobs.tar.gz

cp /tmp/config.xml .

====

restart the container

it's in:

/var/lib/docker/volumes/jenkins_home

### export/import jobs

### all of them

sudo bash

cd /var/lib/docker/volumes/jenkins_home/_data

jobs 

copy this over to the new machine

also copy the views over:

cp /tmp/unzip/jenkins_home/_data/config.xml .



#### get a shell into the new container

docker exec -it 3b7c902c847b /bin/bash

#### get command line jenkins

jenkins@3b7c902c847b:/tmp$ cd /tmp
jenkins@3b7c902c847b:/tmp$ wget http://192.168.42.1:8080/jnlpJars/jenkins-cli.jar
--2020-12-23 18:22:26--  http://192.168.42.1:8080/jnlpJars/jenkins-cli.jar
Connecting to 192.168.42.1:8080... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3139807 (3.0M) [application/java-archive]
Saving to: ‘jenkins-cli.jar’

jenkins-cli.jar                                 100%[=====================================================================================================>]   2.99M  --.-KB/s    in 0.02s   

2020-12-23 18:22:26 (168 MB/s) - ‘jenkins-cli.jar’ saved [3139807/3139807]

#### get a job

java -jar jenkins-cli.jar -logger FINE -s http://192.168.42.1:8080 -auth admin:8eddd7f90dde439da0dec0a4f7ae1a1a get-job am335x-phytec-wega-wic > am335x-phytec-wega-wic.xml

### 



