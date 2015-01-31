#!/bin/bash

if [ ! -e /etc/init.d/mongod ] ; then
  touch /etc/yum.repos.d/mongodb.repo
  tee /etc/yum.repos.d/mongodb.repo <<_EOT_
[mongodb]
name=MongoDB Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/
gpgcheck=0
enabled=1
_EOT_

  yum install -y mongodb-org-2.6.7 mongodb-org-server-2.6.7 mongodb-org-shell-2.6.7 mongodb-org-mongos-2.6.7 mongodb-org-tools-2.6.7
  echo "exclude=mongodb-org,mongodb-org-server,mongodb-org-shell,mongodb-org-mongos,mongodb-org-tools" | tee -a /etc/yum.conf

  sed -i 's/127.0.0.1/ALL/' /etc/mongod.conf
  sed -i 's/#replSet=setname/replSet=rs0/' /etc/mongod.conf

  echo "export LC_ALL=en_US.UTF-8" >> ~/.bash_profile
  localedef  -c -i en_US -f UTF-8 en_US.UTF-8

  service mongod start
  chkconfig mongod on
fi

if [ ! -e /etc/init.d/elasticsearch ] ; then
  yum install -y java-1.7.0-openjdk
  wget -q https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.noarch.rpm
  rpm -i elasticsearch-1.4.2.noarch.rpm
  rm -f elasticsearch-1.4.2.noarch.rpm
  /usr/share/elasticsearch/bin/plugin -s -i elasticsearch/marvel/latest

  service elasticsearch start
  chkconfig elasticsearch on
fi


if [ -e /etc/localtime ] ; then
  echo "Asia/Tokyo" > /etc/timezone
  rm -f /etc/localtime
  ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
fi
