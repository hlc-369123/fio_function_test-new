#!/bin/bash

sshpass -V >/dev/null 2>&1
if [ $? -ne 0 ];then
  rpm -ivh $ROOT_BASE/rpm/sshpass-1.06-2.el7.x86_64.rpm 
fi

for ((IP=$START_IP;IP<=$END_IP;IP++))
do
  sshpass -p $PASSWD scp -r -o ConnectTimeout=10 -o StrictHostKeyChecking=no $ROOT_BASE/rpm/fio root@$SUBNET$IP:/tmp
  sshpass -p $PASSWD ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$SUBNET$IP /tmp/fio/setup_fio.sh $SUBNET$IP
  wait
done
