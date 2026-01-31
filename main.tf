resource "aws_instance" "example" {
  ami           = "ami-019715e0d74f695be"   # Amazon Linux 2 AMI (example)
  instance_type = "t3.micro"

  tags = {
    Name = "MyFirstInstance"
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Allow HTTP and HTTPS inbound traffic"
  vpc_id      = "vpc-0add612466eab90e5"   # Replace with your VPC ID

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "my-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-0a4cd3c99bdd9a8ff"] # Replace with your subnet IDs

  tags = {
    Name = "my-app-lb"
  }
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "my-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0add612466eab90e5"   # Replace with your VPC ID

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "my-app-tg"
  }
}

# Listener for Load Balancer
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

