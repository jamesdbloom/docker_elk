## elasticsearch, logstash & kibana (ELK)

This repository contains a **Dockerfile** to create a docker container with elasticsearch, logstash & kibana (ELK) on ubuntu

This **Dockerfile** has been published as a [trusted build](https://registry.hub.docker.com/u/jamesdbloom/docker-elk/) to the public [Docker Registry](https://index.docker.io/).


### Dependencies

* [dockerfile/java](http://dockerfile.github.io/#/java)


### Installation

1. Install [Docker](https://www.docker.io/).

2. Download [trusted build](https://registry.hub.docker.com/u/jamesdbloom/docker-elk/) from public [Docker Registry](https://index.docker.io/): 
 
```bash
docker pull jamesdbloom/docker-elk
```

**OR** build from Dockerfile: 
   
```bash
git clone https://github.com/jamesdbloom/docker_elk.git
docker build -t="jamesdbloom/docker-elk" .
```


### Usage

```bash
docker run -i -t -name docker-elk -rm jamesdbloom/docker-elk
```

    
[James D Bloom](http://blog.jamesdbloom.com)
