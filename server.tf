resource "aws_launch_configuration" "as_conf" {
  name          = "web_config1"
  image_id      = "ami-04db49c0fb2215364"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "web" {
  name = "${aws_launch_configuration.as_conf.name}-asg"

  min_size             = 1
  desired_capacity     = 1
  max_size             = 1
  
  health_check_type    = "ELB"
  load_balancers = [
    aws_elb.web_elb.id
  ]
  
  launch_configuration = aws_launch_configuration.as_conf.name

    vpc_zone_identifier  = [
    aws_subnet.main.id,
    aws_subnet.main1.id
  ]

}

resource "aws_autoscaling_policy" "web_policy_up" {
  name = "web_policy_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  period = "120"
  statistic = "Average"
  threshold = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [ aws_autoscaling_policy.web_policy_up.arn ]
}
