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
tools_ec2_ip              = "3.255.177.47/32"

####################### EC2 variables ############
ami_id               = "ami-0043735dd4439caed" // an Ubuntu 22.04 LTS amd64

######################## Load_balancer variables  ######################
dashboard_node_port  = "30865"