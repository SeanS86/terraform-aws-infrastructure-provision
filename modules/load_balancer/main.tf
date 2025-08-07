terraform {
  required_version = ">= 1.0.0" # Ensure that the Terraform version is 1.0.0 or higher

  required_providers {
    aws = {
      source = "hashicorp/aws" # Specify the source of the AWS provider
      version = "~> 4.0"        # Use a version of the AWS provider that is compatible with version
    }
  }
}

provider "aws" {
  region = "us-east-1" # Set the AWS region to US East (N. Virginia)
}

resource "aws_lb" "nlb" {
  name               = "nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.public_subnet_id1, var.public_subnet_id2]
}

resource "aws_lb_target_group" "tg_http" {
  name     = "tg-http"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "tg_https" {
  name     = "tg-https"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "tg_attachment_http" {
  target_group_arn = aws_lb_target_group.tg_http.arn
  target_id        = var.k8s_node1_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment_http2" {
  target_group_arn = aws_lb_target_group.tg_http.arn
  target_id        = var.k8s_node2_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment_https" {
  target_group_arn = aws_lb_target_group.tg_https.arn
  target_id        = var.k8s_node1_id
  port             = 443
}

resource "aws_lb_target_group_attachment" "tg_attachment_https2" {
  target_group_arn = aws_lb_target_group.tg_https.arn
  target_id        = var.k8s_node2_id
  port             = 443
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.tg_http.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.tg_https.arn
    type             = "forward"
  }
}