# Latest Amazon Linux 2023 AMI, resolved at plan time (no hard-coded AMI ID)
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_launch_template" "this" {
  name_prefix            = "${var.name_prefix}-lt-"
  image_id               = data.aws_ssm_parameter.ami.insecure_value
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.app_sg_id]
  update_default_version = true

  iam_instance_profile {
    name = var.instance_profile_name
  }

  # IMDSv2 only: blocks SSRF-style theft of instance credentials
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Encrypted root volume
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh.tftpl", {
    project     = var.project_name
    environment = var.environment
    db_host     = var.db_host
    db_port     = var.db_port
  }))

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.name_prefix}-web" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(var.tags, { Name = "${var.name_prefix}-web-root" })
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name_prefix}-asg"
  vpc_zone_identifier       = var.app_subnet_ids # spread across 2 AZs
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  target_group_arns         = var.target_group_arns
  health_check_type         = "ELB" # replace instances the ALB reports unhealthy
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  # A new launch template version rolls out instance by instance
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-web"
    propagate_at_launch = false # instance tags come from the launch template
  }

  lifecycle {
    # After creation, capacity belongs to the scaling policy and the scaling test
    ignore_changes = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.name_prefix}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target
  }
}
