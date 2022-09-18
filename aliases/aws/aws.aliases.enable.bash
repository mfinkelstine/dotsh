#!/usr/bin/env bash
function awsenv() {
  if [ -z ${AWS_SECRET_ACCESS_KEY} ] && [ -z ${AWS_ACCESS_KEY_ID} ] ;then
  	printf "[INFO  ] You Are Working on %s" "${ENV_NAME}"
  else
	printf "[INFO ] %s\n" " NO ENV WAS DEFINED"
  fi
}

function awssetenv(){
	local env_name=$1
	printf "[INFO  ] AWS Configured %s" ${env_name}
    awschecksource() ${env_name}
    source ~/.aws/aws-rnd-i2-${env_name}-box
}

function awsunsetenv() {
	unset AWS_SECRET_ACCESS_KEY
	unset AWS_ACCESS_KEY_ID
	
}

function awschecksource() {
    local env_name=$1
	printf "[INFO  ] Checking if AWS Configuration file exist %s" ${env_name}
    if [[ ! -e ~/.aws/aws-rnd-i2-${env_name}-box ]] ; then
	    printf "[INFO ] AWS %s Environment does not exist please choose from list\n" ${env_name}
		awshelpenv()
	fi
}

function awshelpenv() {
	printf "[INFO  ] %s" "Please Choose environment type"
	printf "[INFO  ] \tAccount\t\tType\t\tPattern"
	printf "[INFO  ] \tSANDBOX\t\tsandbox\t%s" "sandbox || sandbox-api-gw"
	printf "[INFO  ] \tDEVELOPMENT\t\tdevelopment\t%s" "dev || dev-api-gw"
	printf "[INFO  ] \tPRE-PRODUCTION\t\tPRE-PRODUCTION\t%s" "pre-prod || pre-prod-api-gw"
	printf "[INFO  ] \tPRODUCTION \t\tPRODUCTION\t%s" "prod || prod-api-gw"
    exit 1

}


export -f awsenv
export -f awssetenv
export -f awsunsetenv

# DPP AWS
alias awsec2ls="aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],InstanceId,State.Name,InstanceType,PrivateIpAddress,PublicIpAddress,ImageId,LaunchTime]' --filters Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped --output table --region eu-west-1"
alias awslsami="aws ec2 describe-images --query 'Images[*].[Tags[?Key==`Name`].Value|[0],Name,ImageId,State,CreationDate]' --filters Name=image-type,Values=machine Name=is-public,Values=false --output table --region eu-west-1"
alias awss3ls="aws s3api list-buckets --query 'Buckets[*].[Name]' --output table --region eu-west-1"
alias awsefsls="aws efs describe-file-systems --query 'FileSystems[*].[Name,FileSystemId]' --output table --region eu-west-1"
alias awsvpcls='aws ec2 describe-vpcs --query "Vpcs[*].{Name:Tags[?Key==`Name`].Value|[0],Squad:Tags[?Key==`Squad`].Value|[0],ID:VpcId,CIDR:CidrBlock,DHCP:DhcpOptionsId,State:State}" --filter "Name=isDefault,Values=false" --output table --region eu-west-1'