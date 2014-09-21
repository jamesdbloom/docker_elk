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
	wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
	echo "deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main" >> /etc/apt/sources.list && \
	echo "deb http://packages.elasticsearch.org/logstash/1.4/debian stable main" >> /etc/apt/sources.list && \
	apt-get update

# install elasticsearch
RUN \
	apt-get install -y elasticsearch && \
	sed -i '/# cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml && \
	cat << EOF > /etc/supervisor/conf.d/elasticsearch.conf
[program:elasticsearch]
command=/usr/share/elasticsearch/bin/elasticsearch -f -p /var/run/elasticsearch/elasticsearch.pid \
		-Des.default.path.home=/usr/share/elasticsearch \
		-Des.default.path.logs=/var/log/elasticsearch \
		-Des.default.path.data=/var/lib/elasticsearch \
		-Des.default.path.work=/tmp/elasticsearch \
		-Des.default.path.conf=/etc/elasticsearch
stdout_logfile=/var/log/supervisor/%(program_name)s.log
redirect_stderr=true
stdout_syslog=true
autorestart=true
priority=10
EOF

# install logstash
RUN \
	apt-get install -y logstash && \
	cat << EOF > /etc/supervisor/conf.d/logstash.conf
[program:logstash]
command=/opt/logstash/bin/logstash agent -f /etc/logstash/conf.d/ 
stdout_logfile=/var/log/supervisor/%(program_name)s.log
redirect_stderr=true
stdout_syslog=true
autorestart=true
priority=10
EOF

# install nginx and kibana
RUN \
	apt-get -y install -y nginx && \
	mkdir -p /var/www && \
	wget -O kibana.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz && \
	tar xzf kibana.tar.gz -C /opt && \
	ln -s /opt/kibana-3.1.0 /var/www/kibana && \
	cat << EOF > /etc/supervisor/conf.d/nginx.conf
[program:nginx]
command=/usr/sbin/nginx
stdout_logfile=/var/log/supervisor/%(program_name)s.log
redirect_stderr=true
stdout_syslog=true
autorestart=true
priority=10
EOF

# configure nginx
RUN cat << EOF > /etc/nginx/sites-enabled/default
server {
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;

  server_name           localhost;
  access_log            /var/log/nginx/localhost.access.log;

  location / {
    root  /var/www/kibana;
    index  index.html  index.htm;
  }

  location ~ ^/_aliases$ {
    proxy_pass http://127.0.0.1:9200;
    proxy_read_timeout 90;
  }
  location ~ ^/.*/_aliases$ {
    proxy_pass http://127.0.0.1:9200;
    proxy_read_timeout 90;
  }
  location ~ ^/_nodes$ {
    proxy_pass http://127.0.0.1:9200;
    proxy_read_timeout 90;
  }
  location ~ ^/.*/_search$ {
    proxy_pass http://127.0.0.1:9200;
    proxy_read_timeout 90;
  }
  location ~ ^/.*/_mapping {
    proxy_pass http://127.0.0.1:9200;
    proxy_read_timeout 90;
  }
}
EOF
EXPOSE 80

CMD /usr/bin/supervisord -c /etc/supervisor/supervisord.conf