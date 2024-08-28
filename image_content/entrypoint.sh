#!/bin/bash
umask 002

cat /tmp/.erlang.cookie > /var/lib/rabbitmq/.erlang.cookie
chmod 400 /var/lib/rabbitmq/.erlang.cookie

function update_hostnames_for_rabbitmq_cluster_nodes() {
  sed -i 's/POD_NAMESPACE/'$POD_NAMESPACE'/g' /etc/rabbitmq/rabbitmq.conf
}

update_hostnames_for_rabbitmq_cluster_nodes

/sbin/rsyslogd -i /tmp/rsyslogd.pid
/usr/sbin/rabbitmq-server start