#!/bin/bash

source ./common.sh

APP_NAME="catalogue"
MONGODB_HOST="mongodb.bloombear.fun"
MYSQL_HOST="mysql.bloombear.fun"

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Copy mongo repo"

# Installing mongodb client
dnf install mongodb-mongosh -y &>>$LOG_FILE
validate $? "Install MongoDB client"

# Loading the catalogue data into the database
INDEX=$(mongosh mongodb.bloombear.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    validate $? "Load $APP_NAME products"
else
    echo -e "$APP_NAME products already loaded ... $Y SKIPPING $N"
fi

app_restart
print_total_time