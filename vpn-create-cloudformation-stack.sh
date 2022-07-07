#!/bin/bash -ex

# -e option
# Option to exit immediately if the executed command exits with a non-zero status
#
# -x option
# An option to display the command actually executed in the shell script.
# If a variable is used, the value of that variable is displayed expanded
# 
# reference : https://github.com/AWSinAction/code2/tree/master/chapter05

# Get the default VPC
VpcId="$(aws ec2 describe-vpcs --filter "Name=isDefault, Values=true" --query "Vpcs[0].VpcId" --output text)"

# Get the default subnet
SubnetId="$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VpcId" --query "Subnets[0].SubnetId" --output text)"

# Create a random shared secret
# If you specify -base64, the output will be [0-9a-zA-Z + /] in regular expression. 
# Also, the character length is 4 (n / 3), where n is the specified number of bytes (n / 3 is rounded up). 
# However, if n is not a multiple of 3, it is padded with = at the end.
SharedSecret="$(openssl rand -base64 30)"

# Create a random password
Password="$(openssl rand -base64 30)"

# Create a CloudFormation stack
aws cloudformation create-stack --stack-name vpn --template-url https://s3.amazonaws.com/awsinaction-code2/chapter05/vpn-cloudformation.yaml --parameters ParameterKey=KeyName,ParameterValue=mykey "ParameterKey=VPC,ParameterValue=$VpcId" "ParameterKey=Subnet,ParameterValue=$SubnetId" "ParameterKey=IPSecSharedSecret,ParameterValue=$SharedSecret" ParameterKey=VPNUser,ParameterValue=vpn "ParameterKey=VPNPassword,ParameterValue=$Password"

# Wait for the stack to be CREATE_COMPLETE
aws cloudformation wait stack-create-complete --stack-name vpn

# Output the stack
aws cloudformation describe-stacks --stack-name vpn --query "Stacks[0].Outputs"