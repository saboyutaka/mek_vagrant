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

  sed -i 's/bind_ip=127.0.0.1/bind_ip=0.0.0.0/' /etc/mongod.conf
  sed -i 's/#replSet=setname/replSet=rs0/' /etc/mongod.conf

  echo "export LC_ALL=en_US.UTF-8" >> /home/vagrant/.bash_profile
  localedef  -c -i en_US -f UTF-8 en_US.UTF-8

  service mongod start
  chkconfig mongod on

  mongo --eval 'rs.initiate()'
fi

if [ ! -e /etc/init.d/elasticsearch ] ; then
  yum install -y java-1.7.0-openjdk
  wget -q https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.noarch.rpm
  rpm -i elasticsearch-1.4.2.noarch.rpm
  rm -f elasticsearch-1.4.2.noarch.rpm
  /usr/share/elasticsearch/bin/plugin -s -i elasticsearch/marvel/latest
  /usr/share/elasticsearch/bin/plugin -s -i elasticsearch/elasticsearch-mapper-attachments/2.4.1
  /usr/share/elasticsearch/bin/plugin -s -i com.github.richardwilly98.elasticsearch/elasticsearch-river-mongodb/2.0.5
  /usr/share/elasticsearch/bin/plugin -s -i mobz/elasticsearch-head

  service elasticsearch start
  chkconfig elasticsearch on

  curl -XPUT 'http://localhost:9200/_river/mongodb/_meta' -d '{"type": "mongodb", "mongodb": {"db": "airbnb", "collection": "listings"}, "index": {"name": "airbnb", "type": "listings"} }'
fi

if [ ! -e /etc/init.d/kibana ] ; then
  curl -sL https://download.elasticsearch.org/kibana/kibana/kibana-4.0.0-beta3.tar.gz | sudo tar zx
  mv kibana-4.0.0-beta3 /opt
  cp /vagrant/kibana.sh /etc/init.d/kibana
  chmod +x /etc/init.d/kibana

  service kibana start
  chkconfig kibana on
fi

if [ -e /etc/localtime ] ; then
  echo "Asia/Tokyo" > /etc/timezone
  rm -f /etc/localtime
  ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
fi
