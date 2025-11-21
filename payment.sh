#!/bin/bash

source ./common.sh

APP_NAME="payment"

check_root
app_setup
python_setup
systemd_setup

app_restart
print_total_time