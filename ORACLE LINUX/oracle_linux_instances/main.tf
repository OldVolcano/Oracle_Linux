resource "aws_instance" "oracle_linux_instances" {
  count                = length(var.subnet_ids)
  ami                  = data.aws_ami.oracle_linux.id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_ids[count.index]
  source_dest_check    = var.source_dest_check
  iam_instance_profile = module.instance_role.iam_instance_profile_name

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

module "instance_role" {
  source          = "git@github.com:nike/terraform-modules//aws_iam_instance_profile?ref=rel/aws_iam_instance_profile/1.1.0"
  name            = var.name_prefix
  description     = "ec2 instance profile for ${var.name_prefix} instances"
  iam_policy_json = var.instance_policy_json
}