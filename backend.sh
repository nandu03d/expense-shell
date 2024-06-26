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

dnf module disable nodejs -y &>>$logFile
validate $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$logFile
validate $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$logFile
validate $? "Installing nodejs

id expense &>>$logFile
if [ $? -ne 0 ]
then
    useradd expense &>>$logFile
    validate $? "Creating expense user"
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi