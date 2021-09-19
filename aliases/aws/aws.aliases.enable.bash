#!/usr/bin/env bash

source $DOTSH

command_exec="aws"

if ! command -v ${command_exec} >/dev/null; then
  printf " ${command_exec} execute not found.\n" >/&2
  printf " Please install ${command_exec} to use aliases.\n" >&2
  return 1
fi

# DPP AWS
alias awsec2ls="aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],InstanceId,State.Name,InstanceType,PrivateIpAddress,PublicIpAddress,ImageId,LaunchTime]' --filters Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped --output table --region eu-west-1"
alias awslsami="aws ec2 describe-images --query 'Images[*].[Tags[?Key==`Name`].Value|[0],Name,ImageId,State,CreationDate]' --filters Name=image-type,Values=machine Name=is-public,Values=false --output table --region eu-west-1"
alias awss3ls="aws s3api list-buckets --query 'Buckets[*].[Name]' --output table --region eu-west-1"
alias awsefsls="aws efs describe-file-systems --query 'FileSystems[*].[Name,FileSystemId]' --output table --region eu-west-1"
alias awsvpcls='aws ec2 describe-vpcs --query "Vpcs[*].{Name:Tags[?Key==`Name`].Value|[0],Squad:Tags[?Key==`Squad`].Value|[0],ID:VpcId,CIDR:CidrBlock,DHCP:DhcpOptionsId,State:State}" --filter "Name=isDefault,Values=false" --output table --region eu-west-1'