instance_type         = "t3.micro"
root_volume_size      = 10
root_volume_type      = "gp3"

vpc_id                = "vpc-095d82d0e53e9df92"
subnet_ids            = ["subnet-0246e3113f8135df7"]
security_group_ids    = ["sg-084acb5e2a11da00f"]

salt_master_ip        = "10.0.0.1"
custom_user_data      = ""

environment_name      = "prod"
team_name             = "devops"
service_name          = "oracle-instance"
oracle_linux_version  = "9"
service_proxy_host    = ""

tags = {
  Environment = "prod"
  Team        = "devops"
}

name_prefix = "oracle"

# Optional overrides (these are no longer needed but listed for completeness)
# iam_instance_profile_name = "oracle"
# instance_policy_json = ""
