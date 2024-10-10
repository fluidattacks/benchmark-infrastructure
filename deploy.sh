#!/bin/bash

#Step 1
echo "Running terraform init..."
terraform init
#Step 2
echo "Applying initial configuration..."
terraform apply -auto-approve
# Step 3
sleep_time=10
echo "Waiting for $sleep_time minutes before updating the security group..."

while [ $sleep_time -gt 0 ]; do
    echo "Time remaining before updating the security group: $sleep_time minute(s)"
    sleep 60
    sleep_time=$((sleep_time - 1))
done

# Step 4
echo "Updating the security group..."
sed -i '' 's/aws_security_group\.initial_access/aws_security_group\.allow_egress_ips/' main.tf

# Step 5
echo "Applying changes..."
terraform apply -auto-approve

echo "Process completed."
