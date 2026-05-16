resource "aws_security_group" "alb_sg" {
  name = "${var.tags["Environment"]}-alb-sg"
  description = "Allow HTTP traffic from the internet"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.tags["Environment"]}-alb-sg" })
}

resource "aws_security_group" "ec2_sg" {
  name = "${var.tags["Environment"]}-frontend-ec2-sg"
  description = "Allow HTTP traffic only from ALB"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP from ALB"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.tags["Environment"]}-frontend-ec2-sg" })
}

# ------------------------------------------------------------------------------
# Application Load Balancer
# ------------------------------------------------------------------------------

resource "aws_lb" "frontend_alb" {
  name = "${var.tags["Environment"]}-frontend-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = var.public_subnet_ids

  tags = merge(var.tags, { Name = "${var.tags["Environment"]}-frontend-alb" })
}

resource "aws_lb_target_group" "frontend_tg" {
  name = "${var.tags["Environment"]}-frontend-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout = 5
    interval = 10
    matcher = "200"
  }
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# ------------------------------------------------------------------------------
# Launch Template & Auto Scaling Group
# ------------------------------------------------------------------------------

resource "aws_launch_template" "frontend_lt" {
  name_prefix = "${var.tags["Environment"]}-frontend-lt-"
  image_id = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from the Frontend in ${var.tags["Environment"]}</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.tags["Environment"]}-frontend-instance" })
  }
}

resource "aws_autoscaling_group" "frontend_asg" {
  name                = "${var.tags["Environment"]}-frontend-asg"
  vpc_zone_identifier = var.private_subnet_ids # Placing instances in private subnets
  target_group_arns   = [aws_lb_target_group.frontend_tg.arn]
  
  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.frontend_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.tags["Environment"]}-frontend-asg"
    propagate_at_launch = true
  }
}