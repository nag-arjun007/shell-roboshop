#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/$0.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

USERID=$(id -u)
R="\e[31m"
G="\e[31m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $R please run this script with root access $N"| tee -a $LOG_FILE
    exit 1
fi

VALIDATE(){
    if [ $2 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $1 ... $G FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $1 ... $Y SUCCESS $N" | tee -a $LOG_FILE
    fi        
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE "Adding mongo repo" $?

dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE "Installing Mongodb" $?

systemctl enable --now mongod
VALIDATE "Starting and enabling mongoDB" $?

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE "Allowing remote connections to mongoDB" $?

systemctl restart mongod
VALIDATE "restarting mongodb" $?