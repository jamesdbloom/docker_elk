#
# elasticsearch, logstash & kibana (ELK) on ubuntu dockerfile
#
# https://github.com/jamesdbloom/docker_elk
#

# pull base image
FROM dockerfile/java:oracle-java8

# maintainer details
MAINTAINER "James D Bloom <jamesdbloom@gmail.com>"

# update and add standard packages
RUN \
	export DEBIAN_FRONTEND=noninteractive && \
	sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
	apt-get update && \
	apt-get -y upgrade && \
	apt-get install -y vim wget curl lsof locate supervisor

# elasticsearch repos 
RUN \
	export DEBIAN_FRONTEND=noninteractive && \
	wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
	if ! grep "elasticsearch" /etc/apt/sources.list; then echo "deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main" >> /etc/apt/sources.list;fi && \
	if ! grep "logstash" /etc/apt/sources.list; then echo "deb http://packages.elasticsearch.org/logstash/1.4/debian stable main" >> /etc/apt/sources.list;fi && \
	apt-get update

# install elasticsearch
RUN \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get install -y elasticsearch && \
	sed -i '/# cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml && \
	sed -i '/# path.data:.*/a path.data: /mnt/data/data' /etc/elasticsearch/elasticsearch.yml

# configure elasticsearch
ADD etc/supervisor/conf.d/elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf

# install logstash
RUN \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get install -y logstash

# configure logstash
ADD etc/logstash.conf /etc/logstash.conf
ADD etc/supervisor/conf.d/logstash.conf /etc/supervisor/conf.d/logstash.conf

# install nginx and kibana
RUN \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get -y install -y nginx && \
	if ! grep "daemon off" /etc/nginx/nginx.conf; then sed -i '/worker_processes.*/a daemon off;' /etc/nginx/nginx.conf;fi && \
	mkdir -p /var/www && \
	wget -O kibana.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz && \
	tar xzf kibana.tar.gz -C /opt && \
	ln -s /opt/kibana-3.1.0 /var/www/kibana

# configure nginx
ADD etc/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default

EXPOSE 80

CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf