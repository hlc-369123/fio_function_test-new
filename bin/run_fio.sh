#!/bin/bash

RED_COLOUR="\033[1;5;40;36m"
RES="\033[0m"
fio_test_name=1
for rw_mode_block in $(grep rw_mode $ROOT_BASE/param.conf|cut -f2)
do 
  eval $(echo "$rw_mode_block"|awk -F ";" '{print "rw_mode="$1";block_size="$2}')
  size=$(grep size $ROOT_BASE/param.conf|cut -f2)
  runtime=$(grep runtime $ROOT_BASE/param.conf|cut -f2)
  numjobs=$(grep numjobs $ROOT_BASE/param.conf|cut -f2)
  for iodepth in $(grep iodepth $ROOT_BASE/param.conf|cut -f2)
  do
    for ((IP=$START_IP;IP<=$END_IP;IP++))
    do
      flag='False'
      sshpass -p $PASSWD ssh root@$SUBNET$IP -o StrictHostKeyChecking=no "grep 'disk_name=' /tmp/judge.sh|egrep 'sd|vd|hd'" >/dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo "No disk,Skip the node!..."
        continue
      fi

      if [[ "$rw_mode" == "" && "$iodepth" == "" && "$block_size" == "" && "$fio_test_name" == "" && "$size" == "" && "$runtime" == "" && "$numjobs" == "" && "$flag" == "" ]]; then
        echo "Please check $ROOT_BASE/param.conf or "$0"!"
        exit 1
      fi

      if [[ "$rw_mode" == "flag" && "$block_size" == "stop" ]]; then
        flag='True'
        sshpass -p $PASSWD ssh root@$SUBNET$IP -o StrictHostKeyChecking=no "/tmp/judge.sh ${flag}"
      else
        echo -e "$SUBNET$IP:${RED_COLOUR}>>>${RES}${rw_mode}_${iodepth}_${block_size}"
        {
        sshpass -p $PASSWD ssh root@$SUBNET$IP -o StrictHostKeyChecking=no "/tmp/judge.sh ${flag} ${rw_mode} ${iodepth} ${block_size} ${fio_test_name} ${size} ${runtime} ${numjobs}"
        }&
      fi

      ((fio_test_name++))
    done
    wait
    if [ "$flag" == "False" ];then echo '################';fi
    sleep 3
  done
done
