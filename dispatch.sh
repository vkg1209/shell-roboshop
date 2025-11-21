#!/bin/bash

source ./common.sh

APP_NAME="dispatch"

check_root
app_setup
golang_setup
systemd_setup

systemctl enable dispatch
validate $? "Enabling dispatch"

app_restart
print_total_time