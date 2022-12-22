#!/bin/bash
LOG_FILE="stopped_svc_start.log"
if [ -f .env ] ;
    then
	. .env
    else
	read -p "Please, type full path to your ssh-key (i.g. ~/.ssh/my-key_rsa) ... " "SSH_KEY" && \
	read -p "Please, type your remote user-name ... " "REMOTE_USER" && \
	echo "SSH_KEY=${SSH_KEY}" >> .env && \
	echo "REMOTE_USER=${REMOTE_USER}" >> .env
fi
[[ -n ${SSH_KEY} && -n ${REMOTE_USER} ]] || \
	{ echo -e "Please, create .env file with SSH_KEY= and REMOTE_USER= values and start over..." ; exit 1 ; }
LOGIN="ssh -i $SSH_KEY -o StrictHostKeyChecking=no $REMOTE_USER"
FILE="ip_list.txt"
[[ -f ${FILE} ]] || \
	{ echo -e "Please, create the 'ip_list.txt' file with a list of remote servers... " ; exit 1 ;}
# Uncomment if you want to log output to file:
#exec 1>>$LOG_FILE

for IP in $(cat $FILE)
  do
# grep according to your service-names. This script searches for Go (Golang compiled binaries) services.
  SVC_STOPPED=$($LOGIN@$IP sudo rc-status -s | grep go | grep stopped | awk '{print $1}')
  	if [ "$SVC_STOPPED" ]
  	  then 
             echo -e "\e[0;32m$SVC_STOPPED\e[0m is stopped. \e[0;41m$(date +%d-%m-%Y_%H-%M-%S)\e[0m" ; \
	     # Uncomment lines below to send report to Telegram bot:
	     #for i in $SVC_STOPPED
	     #  do $LOGIN@$IP  pgrep $i || telegram-send.sh "$i is stopped. $(date +%d-%m-%Y_%H-%M-%S)" ;
	     #  done
  	     for i in $SVC_STOPPED
	        do $LOGIN@$IP pgrep $i || $LOGIN@$IP sudo service $i start ;
	       	done
	fi
  done
