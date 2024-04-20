#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0|cut -d "." f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

validate(){
    if [ $1 -ne 0]
    then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2....#G SUCCESS $N"

    fi 
}

if [ $USERID -ne 0 ]
then
    echo "you need to have super user privilages to run the script"
    exit 1
else
    echo "You are super user"
fi

dnf install mysql-server -y &>>$LOG_FILE
validate $? "Installation of mysql is"

systemctl enable mysqld &>>$LOG_FILE
validate $? "Enabling mysql is"

systemctl start mysqld &>>$LOG_FILE
validate $? "Starting mysql is"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
validate $? "mysql secure installation is"