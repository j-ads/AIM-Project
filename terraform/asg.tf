# aws_autoscaling_group resource takes a target_group_arns parameter that will register the ASG 
# with the target group so that all instances are registered with the load balancer's target group 
# as they come up and properly drained from the load balancer before being terminated.

# autoscaling group
resource "aws_autoscaling_group" "alb_asg" {
  name = "autoScaling_group"
  availability_zones = ["eu-central-1a"]
  max_size           = 2
  desired_capacity   = 1
  min_size           = 1
  target_group_arns  = ["${aws_lb_target_group.lb-tg.arn}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "frontend"
    propagate_at_launch = true
  }

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }
}

#EC Webserver Template
resource "aws_launch_template" "frontend" {
  name = "frontend"
  image_id = "ami-0bd99ef9eccfee250"
  instance_type = "t2.micro"
  key_name = aws_key_pair.publickey.key_name
  depends_on = [aws_lb.lb]

  lifecycle {
        create_before_destroy = true
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    subnet_id = "${aws_subnet.publicsubnets[0].id}"
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.public.id}"]
  }
  
  user_data = "${filebase64("${path.module}/front.sh")}"

}
# autoscaling attachment  
resource "aws_autoscaling_attachment" "asg_attachment" {
  alb_target_group_arn   = "${aws_lb_target_group.lb-tg.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.alb_asg.id}"
  
}
 
