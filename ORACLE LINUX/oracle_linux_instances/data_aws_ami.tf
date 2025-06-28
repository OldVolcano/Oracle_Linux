variable "oracle_linux_version" {
  description = "Oracle Linux major version to install (e.g., 8 or 9)"
  type        = string
  default     = "9"

  validation {
    condition     = contains(["8", "9"], var.oracle_linux_version)
    error_message = "The value for oracle_linux_version must be one of [\"8\", \"9\"]."
  }
}

data "aws_region" "current" {}

data "aws_ami" "oracle_linux" {
  most_recent = true
  owners      = ["131827586825"]  # Oracle's official AWS account

  filter {
    name   = "name"
    values = ["OL${var.oracle_linux_version}*-x86_64*"]
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
