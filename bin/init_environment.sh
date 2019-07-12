#!/bin/bash

RED_COLOUR="\033[33m"
RES="\033[0m"
ROOT_BASE="/root/fio_function_test"
PARAM_FILE="$ROOT_BASE/param.conf"

if [ -f "$PARAM_FILE" ]; then
  SMALL_SALT=`grep SMALL_SALT $PARAM_FILE | cut -f2`
  PASSWD=`grep PASSWD $PARAM_FILE | cut -f2`
  SUBNET=`grep SUBNET $PARAM_FILE | cut -f2`
  START_IP=`grep START_IP $PARAM_FILE | cut -f2`
  END_IP=`grep END_IP $PARAM_FILE | cut -f2`
else
  echo "Did not find the param.conf file here, will create it for you"
fi

read -e -p "Default VM SUBNET is [$SUBNET]: " -i "$SUBNET" SUBNET
read -e -p "Default VM START_IP is [$START_IP]: " -i "$START_IP" START_IP
read -e -p "Default VM END_IP is [$END_IP]: " -i "$END_IP" END_IP
read -e -p "Default VM root password is [$PASSWD]: " -i "$PASSWD" PASSWD

# If you want to print TAB, must with option -e
echo -e "SUBNET\t$SUBNET
START_IP\t$START_IP
END_IP\t$END_IP
PASSWD\t$PASSWD
ROOT_BASE\t$ROOT_BASE
SMALL_SALT\t$SMALL_SALT

[fio_conf]
size:\t30
iodepth:\t64
numjobs:\t8
runtime:\t300
rw_mode:\twrite;4
rw_mode:\tread;4
rw_mode:\trandwrite;1024
rw_mode:\trandread;1024
rw_mode:\tflag;stop" > $ROOT_BASE/param.conf
echo -e "You can customize the $RED_COLOUR"[fio_conf]"$RES configuration items in the$RED_COLOUR $ROOT_BASE/param.conf !$RES\n"

# Speical Variable - /root/.bash_profile
echo "# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
       . ~/.bashrc
fi

# User specific environment and startup programs

PATH=\$PATH:\$HOME/bin:$ROOT_BASE/bin:$ROOT_BASE/sbin; export PATH
SUBNET=$SUBNET; export SUBNET
START_IP=$START_IP; export START_IP
END_IP=$END_IP; export END_IP
PASSWD=$PASSWD; export PASSWD
ROOT_BASE=$ROOT_BASE; export ROOT_BASE" > /root/.bash_profile
