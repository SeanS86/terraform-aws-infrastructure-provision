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

resource "aws_lb_target_group" "tg_dashboard_https" {
  name     = "${var.project_name}-tg-dashboard-https"
  port     = var.dashboard_node_port
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled  = true
    protocol = "TCP"
    port     = var.dashboard_node_port
  }

  tags = {
    Name    = "${var.project_name}-tg-dashboard-https"
    Project = var.project_name
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment_dashboard_node1" {
  target_group_arn = aws_lb_target_group.tg_dashboard_https.arn
  target_id        = var.k8s_node1_id
  port             = var.dashboard_node_port # CRITICAL: Target instance port is the NodePort
}

resource "aws_lb_target_group_attachment" "tg_attachment_dashboard_node2" {
  target_group_arn = aws_lb_target_group.tg_dashboard_https.arn
  target_id        = var.k8s_node2_id
  port             = var.dashboard_node_port # CRITICAL: Target instance port is the NodePort
}

# --- Listener for Kubernetes Dashboard (HTTPS) ---
resource "aws_lb_listener" "listener_dashboard_https" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.tg_dashboard_https.arn
    type             = "forward"
  }

  tags = {
    Name    = "${var.project_name}-nlb-listener-dashboard-https"
    Project = var.project_name
  }
}

