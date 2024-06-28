#!/bin/bash
userid=$(id -u)
timeStamp=$(date +%F-%H-%M-%S)
scriptName=$(echo $0 | cut -d "." -f1)
logFile=/tmp/$scriptName-$timeStamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $userid -ne 0 ]
then
    echo "please run this script with root access"
    exit 1
else
    echo "you are super user"
fi

validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

dnf install nginx -y &>>$logFile
validate $? "Installing nginx"

systemctl enable nginx &>>$logFile
validate $? "Enabling nginx"

systemctl start nginx &>>$logFile
validate $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$logFile
validate $? "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logFile
validate $? "Downloading frontend code"

cd /usr/share/nginx/html &>>$logFile
unzip /tmp/frontend.zip &>>$logFile
validate $? "Extracting frontend code"

#check your repo and path
cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$logFile
validate $? "Copied expense conf"

systemctl restart nginx &>>$logFile
validate $? "Restarting nginx"