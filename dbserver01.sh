#!/bin/bash
#In most of the linux servers all the package installation are done by admin so befor running the script, we need to check if the user is super user or normal user 
#If we need to check who is running the script, normal user or super user, do as below
#If the user is not super user then the script throws error otherwise it proceeds further
USERID=$(id -u)
#We need to store all the logs in a file in any programming/scripting so creating a log file 
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Please enter your root password:"
read PASSWORD

if [ $USERID -ne 0 ]
then 
   echo -e "$R Please run the script using root privilages $N"
   exit 1
else
   echo -e "$G You are super user $N"
fi
#If the exit status of the command is 0 then the script proceeds otherwise it exits
#In scripting if any block of code is repeating then we can put it in function and call it through the function name

validate(){
if [ $1 -eq 0 ]
then
  echo -e "$2...$G SUCCESS $N"
else
  echo -e "$2....$R FAILURE $N"
  exit 1
fi
}

dnf install mysql-server -y &>>$LOG_FILE
validate $? "Installation of mysql server"

systemctl enable mysqld &>>$LOG_FILE
validate $? "Enabling of mysql server"

systemctl start mysqld &>>$LOG_FILE
validate $? "Starting of mysql server"

#Bydesfault shell scripting is not idempotent in nature, so it's users responsibility to make it idempotent manually
mysql -h db.expensesnote.site  -uroot -p$PASSWORD -e "show databases;" &>>$LOG_FILE
if [ $? -eq 0 ]
then    
    echo -e "Mysql root password is already set...$Y SKIPPING $N";
else
#This command is not idempotent in nature, so we need to make it idempotent
    mysql_secure_installation --set-root-pass $PASSWORD &>>$LOG_FILE
    validate $? "Setting up root password for mysql server"
fi