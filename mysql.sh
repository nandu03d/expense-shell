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

dnf install mysql-server -y &>>$logFile
validate $? "Installing MySQL Server"

systemctl enable mysqld &>>$logFile
validate $? "Enabling MySQL Server"

systemctl start mysqld &>>$logFile
validate $? "Starting MySQL Server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$logFile
# validate $? "Setting up root password"

#Below code will be useful for idempotent nature
mysql -h db.expdev-1.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$logFile #db.expdev-1 is db ip address
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$logFile
    validate $? "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi
