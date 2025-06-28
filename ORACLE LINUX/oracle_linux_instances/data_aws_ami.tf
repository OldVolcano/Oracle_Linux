variable "oracle_linux_version" {
  default = "9"
}

data "aws_region" "current" {}

locals {
  # fallback AMI map if dynamic lookup fails
  oracle_ami_static = {
    "us-east-1" = {
      "9" = "ami-04b70fa74e45c3917"
    }
  }

  ami_name = {
    "9" = "OL9*-x86_64*"
  }

  ami_owner = {
    "9" = "131827586825"
  }
}

data "aws_ami" "oracle_linux" {
  most_recent = true
  owners      = [local.ami_owner[var.oracle_linux_version]]

  filter {
    name   = "name"
    values = [local.ami_name[var.oracle_linux_version]]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Fallback to static AMI ID if dynamic fails
locals {
  final_ami_id = coalesce(
    try(data.aws_ami.oracle_linux.id, null),
    lookup(
      lookup(local.oracle_ami_static, data.aws_region.current.name, {}),
      var.oracle_linux_version,
      null
    )
  )
}

output "oracle_linux_ami_id" {
  value = local.final_ami_id
}