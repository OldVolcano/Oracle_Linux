variable "oracle_linux_version" {
  type    = string
  default = "9"

  validation {
    condition     = contains(["8", "9"], var.oracle_linux_version)
    error_message = "The value for oracle_linux_version must be one of [\"8\", \"9\"]."
  }
}

data "aws_region" "current" {}

locals {
  oracle_ami_static = {
    "us-east-1" = {
      "9" = "ami-04b70fa74e45c3917"
      "8" = "ami-0bb6af715826253bf"
    }
  }

  ami_name = {
    "9" = "OL9*-x86_64*"
    "8" = "OL8*-x86_64*"
  }

  ami_owner = {
    "9" = "131827586825"
    "8" = "131827586825"
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

