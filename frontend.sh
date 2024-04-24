#!/bin/bash
source ./common.sh

checkUSERID

dnf install nginx -y &>>$LOG_FILE

 
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

#rm -rf /etc/nginx/default.d/*.conf
cp /home/ec2-user/expensesshellscripting/expense1.conf  /etc/nginx/default.d/expense1.conf &>>$LOG_FILE
validate $? "configuring frontend to backend connection is"

systemctl restart nginx &>>$LOG_FILE
validate $? "restarting nginx is"