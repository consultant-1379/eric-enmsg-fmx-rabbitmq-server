#!/bin/sh

START_FLAG=/var/lib/rabbitmq/.start
if [ -f ${START_FLAG} ]; then
  rabbitmqctl node_health_check
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    rabbitmqctl status
    exit $?
  fi
  rm -f ${START_FLAG}
  exit ${RESULT}
fi
/etc/rabbitmq/rabbitmq-api-check.sh