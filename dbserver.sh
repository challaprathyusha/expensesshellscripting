#!/bin/bash

set -e 
source ./common.sh

checkUSERID

echo "Please enter your password:"
read -s PASSWORD

dnf install mysql-server -y &>>$LOG_FILE
#validate $? "Installation of mysql is"

systemctl enable mysqld &>>$LOG_FILE
#validate $? "Enabling mysql is"

systemctl start mysqld &>>$LOG_FILE
#validate $? "Starting mysql is"

#mysql_secure_installation --set-root-pass $PASSWORD &>>$LOG_FILE
#validate $? "mysql secure installation is"

mysql -h db.expensesnote.site  -uroot -p$PASSWORD -e 'show databases;' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass $PASSWORD &>>$LOG_FILE
    #validate $? "mysql secure installation is"
else
    echo -e  "Mysql rootuser password is already set....$Y skipping $N"
fi
    
    

