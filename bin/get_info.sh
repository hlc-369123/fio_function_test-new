#!/bin/bash

bc -v >/dev/null 2>&1
if [ $? -ne 0 ];then
  rpm -ivh $ROOT_BASE/rpm/bc-1.06.95-13.el7.x86_64.rpm
fi

estimate(){
if [ $? -eq 0 ]; then
  echo -e "successful_${1}!...\n"
fi
}

if [ -d "$ROOT_BASE/fio_test_info" ]; then
  rm -rf $ROOT_BASE/fio_test_info/*
  mkdir -p $ROOT_BASE/fio_test_info/result
else
  mkdir -p $ROOT_BASE/fio_test_info/result
fi

for ((IP=$START_IP;IP<=$END_IP;IP++))
do
  echo -e "$SUBNET$IP :"
  sshpass -p $PASSWD scp -r -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$SUBNET$IP:/tmp/fio $ROOT_BASE/fio_test_info/
  estimate "fio_$SUBNET$IP"
  mv $ROOT_BASE/fio_test_info/fio $ROOT_BASE/fio_test_info/fio_$IP
  mv $ROOT_BASE/fio_test_info/fio_$IP/result/* $ROOT_BASE/fio_test_info/result/ 
done 
wait

file_date=$(date '+%y%m%d%H%M%S')
echo -e "正在生成测试结果中\n......"
#rw_mode=$(ls $ROOT_BASE/fio_test_info/result|awk -F'_' '{print $1}'|sort -u)
rw_mode=$(grep rw_mode $ROOT_BASE/param.conf|cut -f2|grep -v flag|awk -F ';' '{print $1$2}')
for rw_mode in ${rw_mode}
do
  iops_sum=0
  total_bandwidth=0
  avg_delayed=0
  node_num=0
  for rw_mode_file in $(ls $ROOT_BASE/fio_test_info/result|grep ^${rw_mode}*)
  do
    result_info=$(echo ${rw_mode_file} | grep 'rand')
    if [[ "$result_info" != "" ]];then
      readwrite_mode=$(echo ${rw_mode_file}|awk -F '[0-9]' '{print $1}'|awk -F 'rand' '{print $2}')
    else
      readwrite_mode=$(echo ${rw_mode_file}|awk -F '[0-9]' '{print $1}')
    fi

    IOPS=$(cat $ROOT_BASE/fio_test_info/result/${rw_mode_file}|grep ${readwrite_mode}|awk -F 'IOPS=' '{print $2}'|awk '{print $1}')
    result_k=$(echo ${IOPS} | grep 'k')
    if [[ "$result_k" != "" ]];then
      IOPS=$(echo "$IOPS"|awk -F 'k' '{print $1}')
      IOPS=$(echo "scale=6; $IOPS*1000"|bc)
    fi

    io_num=$(cat $ROOT_BASE/fio_test_info/result/${rw_mode_file}|grep "${readwrite_mode}:"|awk '{print $3}')
    if [ $(echo "$io_num"|grep 'KiB') ];then
      bandwidth=$(echo $(echo $io_num|awk -F 'BW=' '{print $2}'|sed s/'KiB\/s'//)|awk '{print $1/1024}')
    elif [ $(echo "$io_num"|grep 'MiB') ];then
      bandwidth=$(echo $io_num|awk -F 'BW=' '{print $2}'|sed s/'MiB\/s'//)
    elif [ $(echo "$io_num"|grep 'GiB') ];then
      bandwidth=$(echo $(echo $io_num|awk -F 'BW=' '{print $2}'|sed s/'GiB\/s'//)|awk '{print $1*1024}')
    fi

    delayed=$(grep "clat(.*):" $ROOT_BASE/fio_test_info/result/${rw_mode_file}|awk -F 'avg=' '{print $2}')
    iops_sum=$(echo $iops_sum $IOPS|awk '{print $1+$2}')
    total_bandwidth=$(echo $total_bandwidth $bandwidth|awk '{print $1+$2}' )
    avg_delayed=$(echo $delayed $avg_delayed|awk '{print $1+$2}')
    fio_arg=$(cat $ROOT_BASE/fio_test_info/result/${rw_mode_file}|head -n1)
    delayed_unit=$(grep "clat(.*):" $ROOT_BASE/fio_test_info/result/${rw_mode_file}|awk -F 'avg=' '{print $1}')

    ((node_num++))
  done
  delayed_stat=$(echo $avg_delayed $node_num|awk '{print $1/$2}')
  echo -e "$fio_arg
  IOPS: $iops_sum
  带宽：$total_bandwidth MiB/s
  $delayed_unit $delayed_stat\n">> $ROOT_BASE/fio_result_info_${file_date}.txt
  sleep 1
done

cd $ROOT_BASE/
cp ./fio_result_info_${file_date}.txt ./fio_test_info/
/usr/bin/tar -czf fio_test_info_${file_date}.tar.gz ./fio_test_info
if [ $? -eq 0 ]; then
  rm -rf ./fio_test_info
fi
if [ ! -d "$ROOT_BASE/fio_result_info" ]; then
  mkdir $ROOT_BASE/fio_result_info
fi
mv ./fio_result_info_${file_date}.txt ./fio_test_info_${file_date}.tar.gz $ROOT_BASE/fio_result_info/
echo "请在"$ROOT_BASE/fio_result_info/fio_result_info_${file_date}.txt"文件中查看测试结果"
