#!/bin/bash

estimate(){
if [ $? -ne 0 ]; then
  echo "stop get disk..."
  exit 1
fi
}

sshpass -V >/dev/null 2>&1
if [ $? -ne 0 ];then 
  rpm -ivh $ROOT_BASE/rpm/sshpass-1.06-2.el7.x86_64.rpm 
fi

for ((IP=$START_IP;IP<=$END_IP;IP++))
do
sshpass -p $PASSWD scp -o ConnectTimeout=10 -o StrictHostKeyChecking=no $ROOT_BASE/bin/judge.sh  $ROOT_BASE/bin/ssh_get_disk.sh $ROOT_BASE/rpm/nmon root@$SUBNET$IP:/tmp
estimate
wait
sshpass -p $PASSWD ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$SUBNET$IP /tmp/ssh_get_disk.sh $SUBNET$IP
estimate
done
