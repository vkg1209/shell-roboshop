#!/bin/bash

source ./common.sh

app_name=redis

check_root

dnf module disable redis -y &>>$LOG_FILE
validate $? "Disabling Default Redis"

dnf module enable redis:7 -y &>>$LOG_FILE
validate $? "Enabling Redis 7"

dnf install redis -y  &>>$LOG_FILE
validate $? "Installing Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
validate $? "Allowing Remote connections to Redis"

systemctl enable redis &>>$LOG_FILE
validate $? "Enabling Redis"

systemctl start redis &>>$LOG_FILE
validate $? "Starting Redis"

print_total_time