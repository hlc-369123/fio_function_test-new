#!/bin/bash

estimate(){
if [ $? -eq 0 ]; then
  echo "successful_destroy_${1}!..."
fi
}

sshpass -V >/dev/null 2>&1
if [ $? -ne 0 ];then
  rpm -ivh $ROOT_BASE/rpm/sshpass-1.06-2.el7.x86_64.rpm
fi

for ((IP=$START_IP;IP<=$END_IP;IP++))
do
  echo -e "$SUBNET$IP :"
  sshpass -p $PASSWD ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$SUBNET$IP rm -rf /tmp/fio
  estimate 'tmp_fio'
  sshpass -p $PASSWD ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$SUBNET$IP rm -f /tmp/judge.sh
  estimate 'tmp_judge'
  sshpass -p $PASSWD ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$SUBNET$IP rm -f /tmp/ssh_get_disk.sh
  estimate 'ssh_get_disk'
  sshpass -p $PASSWD ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$SUBNET$IP rm -f /tmp/nmon
  estimate 'nmon'
  echo -e "\n"
done 
