#!/bin/bash

source ./common.sh

check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
validate $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
validate $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
validate $? "Enabling RabbitMQ Server"

systemctl start rabbitmq-server &>>$LOG_FILE
validate $? "Starting RabbitMQ"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
validate $? "Setting up permissions"

print_total_time