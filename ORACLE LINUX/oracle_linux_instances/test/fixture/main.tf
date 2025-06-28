data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_iam_policy_document" "test_instance_role_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "test_instance_role" {
  name               = "test-instance"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.test_instance_role_trust_policy.json
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test-profile"
  role = aws_iam_role.test_instance_role.name
}

module "non_gi_instance" {
  source = "../.."

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.private.ids

  instance_type      = "t3.micro"
  root_volume_size   = 40
  root_volume_type   = "gp3"
  security_group_ids = []

  iam_instance_profile_name = aws_iam_instance_profile.test_profile.name
  instance_policy_json      = data.aws_iam_policy_document.test_instance_role_trust_policy.json
  salt_master_ip            = "127.0.0.1"
  oracle_linux_version      = "9"

  additional_ebs_volumes = [
    {
      device_name       = "/dev/xvdb"
      volume_size_in_gb = 120
    }
  ]

  service_name     = "tftest"
  environment_name = "tftest"
  team_name        = "sre"
  name_prefix      = "tftest"
}

module "gi_instance" {
  source = "../.."

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.private.ids

  instance_type      = "t3.micro"
  root_volume_size   = 40
  root_volume_type   = "gp3"
  security_group_ids = []

  iam_instance_profile_name = aws_iam_instance_profile.test_profile.name
  instance_policy_json      = data.aws_iam_policy_document.test_instance_role_trust_policy.json
  salt_master_ip            = "127.0.0.1"
  oracle_linux_version      = "9"

  additional_ebs_volumes = [
    {
      device_name       = "/dev/xvdb"
      volume_size_in_gb = 120
    }
  ]

  service_name     = "tftestgi"
  environment_name = "tftest"
  team_name        = "sre"
  name_prefix      = "tftest"
}
