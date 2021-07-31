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
