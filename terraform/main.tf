data "aws_caller_identity" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "sn1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
}


resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt_sn1" {
  subnet_id      = aws_subnet.sn1.id
  route_table_id = aws_route_table.rt.id
}

#resource "aws_route_table_association" "rt_sn2" {
 # subnet_id      = aws_subnet.sn2.id
  #route_table_id = aws_route_table.rt.id
#}

resource "aws_security_group" "sg" {
  name        = "sg"
  description = "sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user_data" {
  template = file("./scripts/user_data.sh")
  }

resource "aws_launch_template" "lt" {
  name                   = "ltemplate"
  image_id               = "ami-02e136e904f3da870"
  instance_type          = "t2.micro"
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.user_data.rendered)
  vpc_security_group_ids = [aws_security_group.sg.id]
}

resource "aws_launch_template" "instace" {
  name                   = "instace"
  image_id               = "ami-02e136e904f3da870"
  instance_type          = "t2.micro"
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.user_data.rendered)
  vpc_security_group_ids = [aws_security_group.sg.id]
}

resource "aws_lb" "lb" {
  name               = "lb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.sn1.id]
  security_groups    = [aws_security_group.sg.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "tg"
  protocol = "HTTP"
  port     = "80"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_listener" "ec2_lb_listener" {
  protocol          = "HTTP"
  port              = "80"
  load_balancer_arn = aws_lb.lb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

#resource "aws_autoscaling_group" "asg" {
 # name                = "asg"
  #desired_capacity    = "4"
 # min_size            = "2"
 # max_size            = "8"
 # vpc_zone_identifier = [aws_subnet.sn1.id]
 # target_group_arns   = [aws_lb_target_group.tg.arn]
 # launch_template {
 #   id      = aws_launch_template.lt.id
 #   version = "$Latest"
 # }
 # depends_on = [
 #   aws_efs_mount_target.mount1,
 #   aws_efs_mount_target.mount2
 # ]
#}