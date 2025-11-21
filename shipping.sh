#!/bin/bash

source ./common.sh

APP_NAME="shipping"
MYSQL_IP="mysql.bloombear.fun"

check_root
app_setup
java_setup
systemd_setup

# Loading Schema to a database
dnf install mysql -y &>>$LOG_FILE
validate $? "Installing mysql"

# Checking if the data is already loaded
mysql -h $MYSQL_IP -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_IP -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $MYSQL_IP -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h $MYSQL_IP -uroot -pRoboShop@1 < /app/db/master-data.sql
else 
    echo -e "Shipping data is already loaded ... $Y SKIPPING $N"
fi

app_restart
print_total_time