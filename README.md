## elasticsearch, logstash & kibana (ELK) on ubuntu dockerfile

This repository contains a **Dockerfile** to create a docker container with elasticsearch, logstash & kibana (ELK) on ubuntu

This **Dockerfile** has been published as a [trusted build](https://registry.hub.docker.com/u/jamesdbloom/docker-elk/) to the public [Docker Registry](https://index.docker.io/).


### Dependencies

* [dockerfile/java](http://dockerfile.github.io/#/java)


### Installation

1. Install [Docker](https://www.docker.io/).

2. Download [trusted build](https://registry.hub.docker.com/u/jamesdbloom/docker-elk/) from public [Docker Registry](https://index.docker.io/): `docker pull jamesdbloom/docker-elk`

   (alternatively, you can build an image from Dockerfile: `docker build -t="jamesdbloom/docker-elk" github.com/jamesdbloom/docker_elk`)


### Usage

docker run -i -t -name docker-elk -rm jamesdbloom/docker-elk
    
[James D Bloom](http://blog.jamesdbloom.com)
