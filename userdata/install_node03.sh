#!/bin/bash
wget https://solution-as-code-publicbucket.obs.cn-north-4.myhuaweicloud.com/Software-installation-package/esl-erlang_23.2-1_centos_7_amd64.rpm
wget https://solution-as-code-publicbucket.obs.cn-north-4.myhuaweicloud.com/Software-installation-package/rabbitmq-server-3.9.11-1.el7.noarch.rpm
yum -y install mesa-libGLU
yum -y install unixODBC
rpm -ivh esl-erlang_23.2-1_centos_7_amd64.rpm
rpm -ivh rabbitmq-server-3.9.11-1.el7.noarch.rpm
rabbitmq-plugins enable rabbitmq_management

{
  echo  "172.16.0.30    $1-node01"
  echo  "172.16.0.31    $1-node02"
  echo  "172.16.0.32    $1-node03"
} >>/etc/hosts

yum -y install expect
/usr/bin/expect <<EOF
spawn scp root@$1-node01:/var/lib/rabbitmq/.erlang.cookie /var/lib/rabbitmq/.erlang.cookie
expect "Are you sure you want to continue connecting (yes/no)?"
send "yes\r"
expect "password:"
send "$2\r"
expect eof
exit
EOF

rabbitmq-server -detached
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl join_cluster rabbit@$1-node01
rabbitmqctl start_app

