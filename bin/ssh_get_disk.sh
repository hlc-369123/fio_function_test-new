#!/bin/bash

RED_COLOUR="\033[1;4;42;31m"
RES="\033[0m"
disk_name=''
host_ip=$1

for i in $(lsblk |grep disk|egrep 'sd|hd|vd'|awk '{print $1}')
do
  disk_type=$(lsblk -o NAME,FSTYPE|grep $i|awk '{print $2}')
  disk_info=$(lsblk -o NAME,SIZE|grep $i)
  if [  "${disk_type}" == '' ];then
    echo -e "${RED_COLOUR}${host_ip}${RES}>>> $disk_info"
    disk_name="$disk_name $(echo "$disk_info" |awk '{print $1}')"
  fi
done

PS3="请选择磁盘序列数字:"
num=1
if [ -z "$disk_name" ];then echo '系统上没有可测试的卷!...';exit 0;fi
select choice in $disk_name Quit Reset
do
  case $choice in
    $choice)
      if [ "$choice" == "Quit" ];then
        break
      elif [ "$choice" == "Reset" ];then
        disk_list=""
        echo "$disk_list"'已重置!'
      elif [ -n "$choice" ];then
        disk_name="\/dev\/$choice:"
        disk_list="$disk_list$disk_name"
        drive_name="$choice;"
        drive_file="$drive_file$drive_name"
        echo "$drive_file"
      elif [ -z "$choice" ];then
        if [ "$num" -ge 3 ];then
          echo "$num)您可以重新运行!..."
          exit 1
        else
          echo "$num)请输入正确的序列号!"
        fi
      ((num++))
    fi
  esac
done

fio_shell='/tmp/judge.sh'
if [ -f "$fio_shell" ];then
  echo -e "${RED_COLOUR}fio 将会对<<<${drive_file}>>>磁盘进行测试！...${RES}\n"
  sed -i s/"disk_name=''"/"disk_name='$disk_list'"/g /tmp/judge.sh
else
  echo "no fio_shell file!"
  exit 1
fi
