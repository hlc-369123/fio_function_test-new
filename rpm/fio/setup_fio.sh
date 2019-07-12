#!/bin/bash

host_ip=$1
RED_COLOUR="\033[31m"
RES="\033[0m"
rpm -q fio >/dev/null 2>&1
if [ "$?" -ne 0 ]; then
  rpm -ivh /tmp/fio/libpmem-1.3-3.el7.x86_64.rpm /tmp/fio/libpmemblk-1.3-3.el7.x86_64.rpm >/dev/null 2>&1
  rpm -ivh /tmp/fio/librdmacm-1.0.21-1.el7.x86_64.rpm >/dev/null 2>&1
  rpm -ivh /tmp/fio/fio-3.1-2.el7.x86_64.rpm >/dev/null 2>&1
else
  echo "${host_ip}:Fio already existed !"
  rm -f /tmp/fio/lib*
  rm -f /tmp/fio/fio-3.1-2.el7.x86_64.rpm
  rm -f /tmp/fio/setup_fio.sh
  exit 0
fi

fio --version >/dev/null 2>&1
if [ "$?" -ne 0 ]; then
  echo -e "${RED_COLOUR}${host_ip}:未能成功安装Fio工具!...${RES}"
else
  echo "${host_ip}:Fio Successful installation !"
fi
rm -f /tmp/fio/lib*
rm -f /tmp/fio/fio-3.1-2.el7.x86_64.rpm
rm -f /tmp/fio/setup_fio.sh
