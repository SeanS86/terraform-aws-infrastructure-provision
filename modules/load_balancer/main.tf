# --- Network Load Balancer ---
resource "aws_lb" "nlb" {
  name               = "${var.project_name}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.public_subnet1_id, var.public_subnet2_id]

  tags = {
    Name    = "${var.project_name}-nlb"
    Project = var.project_name
  }
}

# --- Target Groups ---
resource "aws_lb_target_group" "tg_http" {
  name     = "${var.project_name}-tg-http"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id

  tags = {
    Name    = "${var.project_name}-tg-http"
    Project = var.project_name
  }
}

resource "aws_lb_target_group" "tg_https" {
  name     = "${var.project_name}-tg-https"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  tags = {
    Name    = "${var.project_name}-tg-https"
    Project = var.project_name
  }
}

# --- Target Group Attachments ---
resource "aws_lb_target_group_attachment" "tg_attachment_http" {
  target_group_arn = aws_lb_target_group.tg_http.arn
  target_id        = var.k8s_node1_id
  port             = 80 # the service on k8s_node1 is listening on for HTTP
}

resource "aws_lb_target_group_attachment" "tg_attachment_http2" {
  target_group_arn = aws_lb_target_group.tg_http.arn
  target_id        = var.k8s_node2_id
  port             = 80 # the port the service on k8s_node2 is listening on for HTTP
}

resource "aws_lb_target_group_attachment" "tg_attachment_https" {
  target_group_arn = aws_lb_target_group.tg_https.arn
  target_id        = var.k8s_node1_id
  port             = 443 # the service on k8s_node1 is listening on for HTTPS
}

resource "aws_lb_target_group_attachment" "tg_attachment_https2" {
  target_group_arn = aws_lb_target_group.tg_https.arn
  target_id        = var.k8s_node2_id
  port             = 443 # the service on k8s_node2 is listening on for HTTPS
}

# --- Listeners ---
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP" # For NLB, listener protocol is TCP/TLS/UDP/TCP_UDP

  default_action {
    target_group_arn = aws_lb_target_group.tg_http.arn
    type             = "forward"
  }

  tags = {
    Name    = "${var.project_name}-nlb-listener-http"
    Project = var.project_name
  }
}

resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "443"
  protocol          = "TCP" # For HTTPS traffic on an NLB

  default_action {
    target_group_arn = aws_lb_target_group.tg_https.arn
    type             = "forward"
  }

  tags = {
    Name    = "${var.project_name}-nlb-listener-https"
    Project = var.project_name
  }
}
