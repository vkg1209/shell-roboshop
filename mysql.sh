#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y $>>$LOG_FILE
validate $? "Installing mysql"

systemctl enable mysqld -y $>>$LOG_FILE
validate $? "Enabling mysql"

systemctl start mysqld  
validate $? "Starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 $>>$LOG_FILE
validate $? "Setting root password"

print_total_time