#Cloudwatch and autoscaling policies
#CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "server_alarm" {
  alarm_name = "server_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "70"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.alb_asg.name}"
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions = ["${aws_autoscaling_policy.asg_policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "minus_alarm" {
  alarm_name = "minus_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "10"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.alb_asg.name}"
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions = ["${aws_autoscaling_policy.asg_policy.arn}"]
}

#Auto Scaling Policies
resource "aws_autoscaling_policy" "asg_policy" {
  name = "web_server_asg_add_policy"
  autoscaling_group_name = "${aws_autoscaling_group.alb_asg.name}"
  policy_type = "SimpleScaling"
  scaling_adjustment = "1"
  adjustment_type = "ChangeInCapacity"
}

resource "aws_autoscaling_policy" "minus_policy" {
  name = "minus_policy"
  autoscaling_group_name = "${aws_autoscaling_group.alb_asg.name}"
  policy_type = "SimpleScaling"
  scaling_adjustment = "-1"
  adjustment_type = "ChangeInCapacity"
}

#Auto Scaling Notification
resource "aws_autoscaling_notification" "web_server_asg_notification" {
  group_names = ["${aws_autoscaling_group.alb_asg.name}"]
  notifications = ["autoscaling:EC2_INSTANCE_LAUNCH", "autoscaling:EC2_INSTANCE_TERMINATE", "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"]
  topic_arn = "${aws_sns_topic.server_sns.arn}"
}

#SNS
resource "aws_sns_topic" "server_sns" {
  name = "web_server_sns"
  display_name = "Web Server"
}
