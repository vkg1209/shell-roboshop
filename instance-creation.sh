#!bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

AMI_ID="ami-09c813fb71547fc4f"
SECURITY_GROUP_ID="sg-03c4d065bf7f7f94d"
DOMAIN_NAME="bloombear.fun"

LOG_FOLDER="/var/log/shell-scripting"
LOG_FILE="$LOG_FOLDER/$0.log"

# validating if the command is success or not
VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "$2 ... $G SUCCESS $N"
    else 
        echo -e "$2 ... $R FAILED $N"
        exit 1
    fi
}

# creating an instances and storing the instance ids
for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${instance}}]" --query 'Instances[0].InstanceId' --output text) &>> LOG_FILE
    VALIDATE $? "Creating $instance  Instance"

    if [ $instance == "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text) &>> LOG_FILE
        VALIDATE $? "Getting Public IP Address"
        echo -e "$G Public IP: $N $IP"
        RECORD_NAME="$DOMAIN_NAME"
    else 
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text) &>> LOG_FILE
        VALIDATE $? "Getting Private IP Address"
        echo -e "$G Private IP: $N $IP"
        RECORD_NAME="$instance.$DOMAIN_NAME"
    fi

    aws route53 change-resource-record-sets \
  --hosted-zone-id Z01953923TROREUOJRMSG \
  --change-batch '
  {
    "Comment": "Updating record set"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$RECORD_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
        }]
      }
    }]
  }
  '
    VALIDATE $? "Creating or Updating the DNS Record"
    echo "-------------------------"

done



