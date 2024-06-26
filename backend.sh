#!/bin/bash
userid=$(id -u)
timeStamp=$(date +%F-%H-%M-%S)
scriptName=$(echo $0 | cut -d "." -f1)
logFile=/tmp/$scriptName-$timeStamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Please enter DB password:"
read -s mysql_root_password

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

dnf module disable nodejs -y &>>$logFile
validate $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$logFile
validate $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$logFile
validate $? "Installing nodejs"

id expense &>>$logFile
if [ $? -ne 0 ]
then
    useradd expense &>>$logFile
    validate $? "Creating expense user"
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>$logFile
validate $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$logFile
validate $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$logFile
validate $? "Extracted backend code"

npm install &>>$logFile
validate $? "Installing nodejs dependencies"

#check your repo and path
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$logFile
validate $? "Copied backend service"

systemctl daemon-reload &>>$logFile
validate $? "Daemon Reload"

systemctl start backend &>>$logFile
validate $? "Starting backend"

systemctl enable backend &>>$logFile
validate $? "Enabling backend"

dnf install mysql -y &>>$logFile
validate $? "Installing MySQL Client"

mysql -h db.expdev-1.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$logFile
validate $? "Schema loading"

systemctl restart backend &>>$logFile
validate $? "Restarting Backend"