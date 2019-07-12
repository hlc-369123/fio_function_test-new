#!/bin/bash

RED_COLOUR="\033[31m"
RES="\033[0m"
flag=$1
rw_mode=$2
iodepth=$3
block_size=$4
fio_test_name=$5
disk_name=''
size=$6
runtime=$7
numjobs=$8
#numjobs=$(cat /proc/cpuinfo |grep "processor"|wc -l)
#numjobs=$(echo "$numjobs"*0.1|bc)
result_file="/tmp/fio/result"
if [[ ! -d "$result_file" ]]; then
  mkdir -p ${result_file}
fi
fio_test_file="/tmp/fio/${rw_mode}/test/${rw_mode}${block_size}k_${fio_test_name}"

fio --version >/dev/null 2>&1
if [ "$?" -ne 0 ]; then
  echo -e "${RED_COLOUR}请安装Fio工具!...${RES}"
fi

nmon_course=$(ps -ef|grep '/tmp/nmon'|grep "\-c[0-9]."|awk '{print $2}')
if [ "$nmon_course" == "" ]; then
  /tmp/nmon -f -c120 -s30 -m /tmp/fio
fi

if [ "$flag" == 'True' ]; then
  kill -9 ${nmon_course}
  exit 0
fi

if [ ! -d "$fio_test_file" ]; then
  mkdir -p ${fio_test_file}
fi

run_fio(){
fio --thread --filename=$1 --direct=1 --rw=$2 --numjobs=$3 --iodepth=$4 \
--ioengine=libaio --bs=${5}k --group_reporting --name=lc"${6}" --log_avg_msec=500 \
--write_bw_log=test-fio --write_lat_log=test-fio --write_iops_log=test-fio --size=${7}G --runtime=$8 --time_based
}

cd ${fio_test_file}
run_fio ${disk_name} ${rw_mode} ${numjobs} ${iodepth} ${block_size} ${fio_test_name} ${size} ${runtime} > /tmp/fio/${rw_mode}/${rw_mode}${block_size}k_${fio_test_name}

result=$(echo ${rw_mode} | grep 'rand')
if [[ "$result" != "" ]];then
  readwrite_mode=$(echo ${rw_mode} |awk -F 'rand' '{print $2}')
else
  readwrite_mode=${rw_mode}
fi

run_result(){
echo -e "disk_name:(${disk_name}) ,numjobs:(${numjobs}) ,iodepth:(${iodepth}) ,rw_mode:(${rw_mode}) ,block_size:(${block_size})\n"
echo 'IOPS&吞吐量：'
grep "${readwrite_mode}:" /tmp/fio/${rw_mode}/${rw_mode}${block_size}k_${fio_test_name} |awk '{print $1,$2,$3}'|sed s/,//
echo '延时：'
grep "clat (.*):" /tmp/fio/${rw_mode}/${rw_mode}${block_size}k_${fio_test_name} |awk '{print $1$2,$5}'|sed s/,//
echo '磁盘利用率：'
grep 'util=' /tmp/fio/${rw_mode}/${rw_mode}${block_size}k_${fio_test_name} |awk '{print $1,$NF}'
}
run_result > ${result_file}/${rw_mode}${block_size}k_${fio_test_name}_result.txt
