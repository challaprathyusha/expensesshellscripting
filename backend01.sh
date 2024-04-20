#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
M="\e[35m"
C="\e[36m"
W="\e[34m"
N="\e[0m"
echo "Please enter your root password:"
read PASSWORD

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

dnf module disable nodejs -y &>>$LOG_FILE
validate $? "diasabling nodejs is"
dnf module enable nodejs:20 -y &>>$LOG_FILE
validate $? "enabling nodejs:20 is"
dnf install nodejs -y &>>$LOG_FILE
validate $? "Installation of nodejs is"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then 
    useradd expense &>>$LOG_FILE
    validate $? "expense user creation"
else 
    echo "expense user already exist" 
fi

mkdir /app &>>$LOG_FILE
validate $? "/app directory creation is"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
validate $? "Downloading backend code is"

cd /app
unzip /tmp/backend.zip &>>$LOG_FILE
validate $? "extracting the backend code is"

cd /app
npm install &>>$LOG_FILE
validate $? "Installing nodejs dependencies is"

cp /home/ec2-user/expensesshellscripting/backend.service /etc/systemd/system/backend.service >>$LOG_FILE
validate $? "copying of file is"

systemctl daemon-reload &>>$LOG_FILE
validate $? "daemon reload is"

systemctl start backend &>>$LOG_FILE
validate $? "starting backend is"

systemctl enable backend &>>$LOG_FILE
validate $? "enabling backend is"

dnf install mysql -y &>>$LOG_FILE
validate $? "installing mysql client is"

mysql -h db.expensesnote.site -uroot -p$PASSWORD < /app/schema/backend.sql &>>$LOG_FILE
validate $? "loading schema into db is"

systemctl restart backend &>>$LOG_FILE
validate $? "restarting backend is"