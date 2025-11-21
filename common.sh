#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER_ID=$(id -u)
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE=$"$LOG_FOLDER/$SCRIPT_NAME.log"

# Creating a shell-roboshop log folder if doesnt exist
mkdir -p $LOG_FOLDER
check_root() {
    if [ $USER_ID -ne 0 ]; then
        echo "ERROR: You need ROOT Privilages to execute this script"
        exit 1
    fi
}

validate() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

nodejs_setup() {
    dnf module disable nodejs -y &>>$LOG_FILE
    validate $? "Disabling Nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    validate $? "Enabling Nodejs 20"

    dnf install nodejs -y &>>$LOG_FILE
    validate $? "Installing Nodejs"

    npm install &>>$LOG_FILE
    validate $? "Installing dependencies"
}

java_setup() {
    dnf install maven -y &>>$LOG_FILE
    validate $? "Installing Maven"

    mvn clean package &>>$LOG_FILE
    validate $? "Packing the Application"

    mv target/$APP_NAME-1.0.jar $APP_NAME.jar &>>$LOG_FILE
    validate $? "Renaming the Artifact"
}

python_setup() {
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    validate $? "Installing python 3"

    pip3 install -r requirements.txt &>>$LOG_FILE
    validate $? "Installing dependencies"

}

golang_setup() {
    dnf install golang -y &>>$LOG_FILE
    validate $? "Installing golang"

    go mod init dispatch
    go get 
    go build &>>$LOG_FILE
    validate $? "Installing Dependencies"
}

app_setup() {
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        validate $? "Creating a roboshop System User"
    else
        echo -e "User already exist ... $Y Skipping $N"
    fi

    mkdir -p /app
    validate $? "Creating App directory"

    curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip &>>$LOG_FILE
    validate $? "Downloaded the $APP_NAME application"

    cd /app 
    validate $? "Changing to App directory"

    rm -rf /app/*
    validate $? "Removing the existing code"

    unzip /tmp/$APP_NAME.zip &>>$LOG_FILE
    validate $? "Unzipping $APP_NAME"
}

systemd_setup() {
    cp $SCRIPT_DIR/$APP_NAME.service /etc/systemd/system/$APP_NAME.service
    validate $? "Copy Systemctl Service"

    systemctl daemon-reload
}


app_restart() {
    systemctl restart $APP_NAME
    validate $? "Restarted the $APP_NAME"
}


print_total_time() {
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "Script executed in $Y $TOTAL_TIME s$N"
}