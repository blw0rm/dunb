# Django-zc.buildout-uWSGI-Nginx-Ubuntu configuration of Docker container

from ubuntu:trusty

maintainer Yaroslav Dashivets <yaroslav.dashivets@gmail.com>

# Update packages
run apt-get upgrade -y

# install python2 and dev packages
run apt-get install -y python
run apt-get update -y
run apt-get install -y build-essential
run apt-get install -y python-dev python-setuptools
run apt-get install -y python-software-properties software-properties-common

run apt-get install -y git
run apt-get install -y supervisor

# create docker user
RUN useradd docker -m -s /bin/bash

# install nginx
RUN add-apt-repository -y ppa:nginx/stable
run apt-get update
run apt-get install -y nginx sqlite3

# install code
COPY djangoapp /home/docker/djangoapp
RUN chown -R docker:docker /home/docker/djangoapp

# build project
USER docker
WORKDIR /home/docker/djangoapp
RUN python bootstrap.py
RUN bin/buildout

# setup all the configfiles
USER root
run echo "daemon off;" >> /etc/nginx/nginx.conf
run rm /etc/nginx/sites-enabled/default
run ln -s /home/docker/djangoapp/conf/nginx-django.conf /etc/nginx/sites-enabled/
run ln -s /home/docker/djangoapp/conf/supervisor-django.conf /etc/supervisor/conf.d/

expose 80
cmd ["supervisord", "-n"]
