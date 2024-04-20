#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
M="\e[35m"
C="\e[36m"
W="\e[34m"
N="\e[0m"


if [ $USERID -ne 0 ]
then 
   echo -e "$M Please run the script using root privilages $N"
   exit 1
else
   echo -e "$C You are super user $N"
fi

validate(){
if [ $1 -eq 0 ]
then
  echo -e "$2...$W SUCCESS $N"
else
  echo -e "$2....$C FAILURE $N"
  exit 1
fi
}

dnf install nginx -y &>>$LOG_FILE
validate $? "Installation of nginx is"

systemctl enable nginx &>>$LOG_FILE
validate $? "enabling nginx is"

systemctl start nginx &>>$LOG_FILE
validate $? "starting nginx is"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
validate $? "removing files in folder"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
validate $? "Downloading frontend code is"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE
validate $? "extracting the frontend code is"

rm -rf /etc/nginx/default.d/*.conf
cp /home/ec2-user/expensesshellscripting/expense1.conf  /etc/nginx/default.d/expense1.conf &>>$LOG_FILE
validate $? "configuring frontend to backend connection is"

systemctl restart nginx &>>$LOG_FILE
validate $? "restarting nginx is"