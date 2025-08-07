################ Global variables ###############
region                    = "eu-west-1"
project                   = "Ss86"

################## VPC variables  ################
vpc_cidr                  = "172.18.0.0/16"
public_subnet1_cidr       = "172.18.1.0/24"
public_subnet2_cidr       = "172.18.10.0/24"
private_subnet1_cidr      = "172.18.3.0/24"
private_subnet2_cidr      = "172.18.4.0/24"
availability_zone1        = "eu-west-1a"
availability_zone2        = "eu-west-1b"

####################### SG variables  #################
tools_ec2_ip              = "172.19.0.96"