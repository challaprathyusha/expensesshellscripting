#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

checkUSERID(){
if [ $USERID -ne 0 ]
then
    echo "you need to have super user privilages to run the script"
    exit 1
else
    echo "You are super user"
fi
}

handleerror(){

    echo "error at line:$1,error at command:$2"
}

trap 'handleerror $LINENO "$BASH_COMMAND"' ERR