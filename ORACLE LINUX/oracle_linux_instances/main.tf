# IAM Role and Instance Profile Setup
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.name_prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  description        = "IAM role for EC2 instance ${var.name_prefix}"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.name_prefix}-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 Instances
resource "aws_instance" "oracle_linux_instances" {
  count                = length(var.subnet_ids)
  ami                  = local.final_ami_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  subnet_id            = var.subnet_ids[count.index]
  source_dest_check    = var.source_dest_check
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }

  vpc_security_group_ids = var.security_group_ids

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = true
  }

  dynamic "ebs_block_device" {
    for_each = var.additional_ebs_volumes
    content {
      device_name = ebs_block_device.value.device_name
      volume_size = ebs_block_device.value.volume_size
      volume_type = ebs_block_device.value.volume_type
      encrypted   = true
    }
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      ebs_optimized,
      ebs_block_device,
      ephemeral_block_device,
    ]
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-${count.index}"
    }
  )

  user_data = templatefile("${path.module}/user_data.tpl", {
    hostname           = "${var.name_prefix}-${count.index}"
    salt_master_ip     = var.salt_master_ip
    custom_user_data   = var.custom_user_data
    service_proxy_host = var.service_proxy_host
  })
}
