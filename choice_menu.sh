#!/bin/bash

RED_COLOUR="\033[31m"
RES="\033[0m"
#mune=$(ls $(pwd)/bin)
PS3="请选择要执行得选项序列数字:"
num=1
select choice in init_environment install_fio scp_conf run_fio get_info destroy_conf Quit
do
  case $choice in
    init_environment)
      ./bin/${choice}.sh
      echo -e "Attention !!! Please use # ${RED_COLOUR}source ~/.bash_profile ${RES}to export the variable"
      read -p "Enter any Key to Break...."
      break
      ;;
    install_fio|scp_conf|run_fio|destroy_conf)
      ./bin/${choice}.sh
      if [ $? -ne 0 ]; then
        echo Please check ${choice}.sh
        exit 1
      fi
      echo -e "\n1) init_environment	4) run_fio		7) Quit
2) install_fio		5) get_info
3) scp_conf		6) destroy_conf"
      ;;
    get_info)
      ./bin/${choice}.sh
      if [ $? -ne 0 ]; then
        echo Please check ${choice}.sh
        exit 1
      fi
      echo -e "\n$RED_COLOUR"Successful access to information!"$RES\nProgram exiting !......"&&sleep 0.5
      exit 0
      ;;
    Quit)
      exit 0
      ;;
    *)
      if [ -z "$choice" ];then
        if [ "$num" -ge 3 ];then
          echo "$num)您可以重新运行!..."
          exit 2
        else
          echo "$num)请输入正确的序列号!"
        fi
        ((num++))
      fi
    esac
done
