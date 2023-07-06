# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "casestudy"
    Project = "casestudy"
  }
}
#Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "casestudygw"
    Project = "Multi"
  }
}

# Subnets
resource "aws_subnet" "publicsubnets" {
  availability_zone       = "${element(var.azs,count.index)}"
  cidr_block              = "${element(var.public_subnets_cidr,count.index)}"
  count                   = "${length(var.azs)}"
  map_public_ip_on_launch = true
  vpc_id                  = "${aws_vpc.main.id}"
  tags = {
    Name = "publicsub-${count.index}"
    Project = "Multi"
  }
}


#private submnets
resource "aws_subnet" "privatesubnets" {
  availability_zone       = "${element(var.azs,count.index)}"
  cidr_block              = "${element(var.private_subnets_cidr,count.index)}"
  count                   = "${length(var.azs)}"
  map_public_ip_on_launch = false
  vpc_id                  = "${aws_vpc.main.id}"
  tags = {
    Name = "privatesub-${count.index}"
  }
}
#ELASTIC IPs
resource "aws_eip" "nat_a" {
  vpc = true
}

resource "aws_eip" "nat_b" {
  vpc = true
}

# NAT Gateways
resource "aws_nat_gateway" "ngw_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.publicsubnets[0].id

  tags = {
    Name = "nat-gw-casestudy-a"
  }
}

resource "aws_nat_gateway" "ngw_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.publicsubnets[1].id

  tags = {
    Name = "nat-gw-casestudy-b"
  }
}

# Route Tables
resource "aws_route_table" "public-a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "public-b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}


resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_a.id
  }

  tags = {
    Name = "private-rt-a"
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_b.id
  }

  tags = {
    Name = "private-rt-b"
  }
}

# Subnet - Route Table associations
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.publicsubnets[0].id
  route_table_id = aws_route_table.public-a.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.publicsubnets[1].id
  route_table_id = aws_route_table.public-b.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.privatesubnets[0].id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.privatesubnets[1].id
  route_table_id = aws_route_table.private_b.id
}

# Security Groups
# security group for rds
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "allow incoming traffic for db"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_sg"
    Project = "Multi"
  }
}
resource "aws_security_group" "public" {
  name        = "public sg"
  description = "Allow Ping, SSH and HTTP access for resources in public subnets"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow node/prometheus"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "Allow prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Request to Apache"
    from_port   = 8090
    to_port     = 8090
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
    Name = "public-sg"
  }
}

resource "aws_security_group" "private" {
  name        = "private sg"
  description = "Allow Ping, SSH and HTTP access for resources in private subnets"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Request to News API"
    from_port   = 8090
    to_port     = 8090
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
    Name = "private-sg"
  }
}

resource "aws_security_group" "alb" {
  name        = "alb sg"
  description = "Allow access to 8090"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow Request to Apache"
    from_port   = 8090
    to_port     = 8090
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

#Create rds subnet group

resource "aws_db_subnet_group" "dbsubnet" {
  name = "dbsubnet"
  subnet_ids = "${aws_subnet.privatesubnets.*.id}"
}

#Parameter Group
resource "aws_db_parameter_group" "group6" {
  name   = "rds-pg"
  family = "mysql5.7"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

#Create RDS
resource "random_password" "password" {
  length           = 24
  special          = false
}

resource "aws_db_instance" "rds" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "${var.rds_name}"
  identifier           = "dbmulti"
  username             = "${var.rds_username}"
  password             = random_password.password.result
  parameter_group_name = "${aws_db_parameter_group.group6.id}"
  skip_final_snapshot  = true
  db_subnet_group_name = "${aws_db_subnet_group.dbsubnet.id}"
  port = 3306
  publicly_accessible = false
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  
  tags = {
    Name = "database"
    Project = "Multi"
  }
}

# EC2 instances
resource "aws_instance" "bastion" {
  ami                    = "ami-0bd99ef9eccfee250"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.publickey.key_name
  subnet_id              = aws_subnet.publicsubnets[1].id
  vpc_security_group_ids = [aws_security_group.public.id]

  tags = {
    Name = "bastion"
  }
  provisioner "remote-exec" {
    inline = ["echo 'Waiting for server to be initialized...'"]

    connection {
      type        = "ssh"
      agent       = false
      host        = self.public_ip
      user        = "${var.ec2_user}"
      private_key = "${file("${var.private_key_public}")}"

    }
  }

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook \
        -i '${self.public_ip},' \
        -u "${var.ec2_user}" \
        --private-key ${var.private_key_public} \
        --extra-vars "host=${aws_lb.lb.dns_name}" \
        ../ansible/bastion.yml 
    EOT  
  }
}


resource "aws_instance" "backend-a" {
  ami                         = "ami-0bd99ef9eccfee250"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.privatekey.key_name
  subnet_id                   = aws_subnet.privatesubnets[0].id
  vpc_security_group_ids      = [aws_security_group.private.id]
  associate_public_ip_address = false

  tags = {
    Name = "backend-a"
  }

  depends_on = [aws_instance.bastion]

  # We run this to make sure server is initialized before we run the "local exec"
  provisioner "remote-exec" {
    inline = ["echo 'Waiting for server to be initialized...'"]

    connection {
      type        = "ssh"
      host        = self.private_ip
      user        = "${var.ec2_user}"
      private_key = "${file("${var.private_key_private}")}"
      agent       = false
      bastion_host        = aws_instance.bastion.public_ip
      bastion_private_key = "${file("${var.private_key_public}")}"
    }
  }

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook \
        -i '${self.private_ip},' \
        --ssh-common-args ' \
          -o ProxyCommand="ssh -o StrictHostKeyChecking=no -A -W %h:%p -q ${var.ec2_user}@${aws_instance.bastion.public_ip} \
                               -i ${var.private_key_public}"' \
        -u ${var.ec2_user} \
        --private-key ${var.private_key_private} \
        ../ansible/backend.yml 
    EOT  
  }
}

resource "aws_instance" "backend-b" {
  ami                         = "ami-0bd99ef9eccfee250"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.privatekey.key_name
  subnet_id                   = aws_subnet.privatesubnets[1].id
  vpc_security_group_ids      = [aws_security_group.private.id]
  associate_public_ip_address = false

  tags = {
    Name = "backend-b"
  }

  depends_on = [aws_instance.bastion]

  # We run this to make sure server is initialized before we run the "local exec"
  provisioner "remote-exec" {
    inline = ["echo 'Waiting for server to be initialized...'"]

    connection {
      type       = "ssh"
      user = "${var.ec2_user}"
      private_key = "${file("${var.private_key_private}")}"
      host = self.private_ip
      agent = false
      bastion_host        = aws_instance.bastion.public_ip
      bastion_private_key = "${file("${var.private_key_public}")}"
    }
  }

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook \
        -i '${self.private_ip},' \
        --ssh-common-args ' \
          -o ProxyCommand="ssh -o StrictHostKeyChecking=no -A -W %h:%p -q ${var.ec2_user}@${aws_instance.bastion.public_ip} \
                               -i ${var.private_key_public}"' \
        -u ${var.ec2_user} \
        --private-key ${var.private_key_private} \
        ../ansible/backend.yml
    EOT
  }
}


resource "aws_instance" "frontend" {
  ami                    = "ami-0bd99ef9eccfee250"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.publickey.key_name
  subnet_id              = aws_subnet.publicsubnets[0].id
  vpc_security_group_ids = [aws_security_group.public.id]

  # Need to wait for latest-news-api LB to be created, as we need its DNS
  depends_on = [aws_lb.lb]

  tags = {
    Name = "FrontEnd"
  }

  # We run this to make sure server is initialized before we run the "local exec"
  provisioner "remote-exec" {
    inline = ["echo 'Waiting for server to be initialized...'"]

    connection {
      type        = "ssh"
      agent       = false
      host        = self.public_ip
      user        = "${var.ec2_user}"
      private_key = "${file("${var.private_key_public}")}"

    }
  }

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook \
        -i '${self.public_ip},' \
        -u "${var.ec2_user}" \
        --private-key ${var.private_key_public} \
        --extra-vars "host=${aws_lb.lb.dns_name}" \
        ../ansible/frontend.yml 
    EOT  
  }
}

# Application Load Balancers
resource "aws_lb" "lb" {
  name               = "lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.publicsubnets[0].id, aws_subnet.publicsubnets[1].id]

  tags = {
    Name = "lb"
  }
}

# Target Group
resource "aws_lb_target_group" "lb-tg" {
  name     = "lb-tg"
  port     = 8090
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    interval            = 10
    path                = "/actuator/health"
    port                = 8090
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "lb-tg"
  }
}

# ALB Listeners
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "8090"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tg.arn
  }
}

# ALB Target Group Attachments
resource "aws_lb_target_group_attachment" "target_a" {
  target_group_arn = aws_lb_target_group.lb-tg.arn
  target_id        = aws_instance.backend-a.id
  port             = 8090
}

resource "aws_lb_target_group_attachment" "target_b" {
  target_group_arn = aws_lb_target_group.lb-tg.arn
  target_id        = aws_instance.backend-b.id
  port             = 8090
}
#Private keys creation
  resource "aws_key_pair" "publickey" {
    key_name   = "publickey"
    public_key = file(var.public_key_public)
}

  resource "aws_key_pair" "privatekey" {
    key_name   = "privatekey"
    public_key = file(var.public_key_private)
}
