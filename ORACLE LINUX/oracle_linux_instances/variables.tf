variable "instance_type" {
  validation {
    condition = contains([
      "c5",
      "c5a",
      "c5d",
      "i3",
      "i3en",
      "m5",
      "t3",
    ], element(split(".", var.instance_type), 0))
    error_message = "Instance type must be one of following families [\"c5\",\"c5d\",\"i3\",\"i3en\",\"m5\",\"t3\"]."
  }
}

variable "additional_ebs_volumes" {
  type = list(object({
    device_name       = string
    volume_size_in_gb = number
  }))
  default = []
}
/*
variable "oracle_linux_version" {
  type = string

  validation {
    condition = contains([
      "8",
      "9",
    ], var.oracle_linux_version)
    error_message = "The value for oracle_linux_version must be one of [\"8\"9\"]."
  }
}
*/

variable "iam_instance_profile_name" {
  type = string
}


variable "security_group_ids" {
  description = "List of security-group IDs to attach to the instance"
  type        = list(string)
}

variable "root_volume_size" {
  description = "Size (in GB) for the root EBS volume"
  type        = number
}

variable "root_volume_type" {
  description = "EBS volume type for the root block device (e.g. \"gp3\")"
  type        = string
}


variable "tags" {
  description = "Map of extra tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "salt_master_ip" {
  description = "IP address or hostname of your Salt Master (gets templated into user_data)"
  type        = string
}

variable "custom_user_data" {
  description = "Additional shell commands or cloud-config to append to the user_data script"
  type        = string
  default     = ""
}

variable "vpc_id" {
  type = string

  validation {
    condition     = can(regex("^vpc-.*", var.vpc_id))
    error_message = "The vpc_id value must be prefixed with 'vpc-'."
  }
}

variable "source_dest_check" {
  description = "Whether to enable source/destination checking on the ENI"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "A list of subnet IDs; one instance will be placed in each subnet."
  type        = list(string)
}


variable "service_name" {
  type        = string
  description = "The name of the service (required)."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+[a-z0-9]$", var.service_name))
    error_message = "The service_name value must have the pattern: `^[a-z][a-z0-9-]+[a-z0-9]$`."
  }
}

variable "hosted_zone_name" {
  type        = string
  description = "If non-empty, create DNS records for each EC2 instance in the specified zone."
  default     = ""
}

variable "hosted_zone_config" {
  type = object({
    name = string
    id   = string
  })

  description = "The name and ID of the Route53 zone in which to create a DNS record for the instance; if non-empty, create DNS records for each EC2 instance in the specified zone."

  default = { name = "", id = "" }

  validation {
    condition     = (length(var.hosted_zone_config.name) != 0 && length(var.hosted_zone_config.name) != 0) || ((length(var.hosted_zone_config.name) == 0 && length(var.hosted_zone_config.name) == 0))
    error_message = "The values for `hosted_zone_config` `name` and `id` fields either must both be empty or both be provided."
  }

}

variable "cluster_name" {
  type        = string
  description = "The name used to distinguish multiple instances of a service (optional)."
  default     = ""

  validation {
    condition     = var.cluster_name == "" || can(regex("^[a-z0-9]{1,}$", var.cluster_name))
    error_message = "The cluster_name value must contain at least 1 character and be [a-z0-9]."
  }
}

variable "environment_name" {
  type = string

  validation {
    condition     = length(var.environment_name) > 0
    error_message = "The environment_name value cannot be an empty string."
  }
}

variable "team_name" {
  type = string

  validation {
    condition     = length(var.team_name) > 0
    error_message = "The team_name value cannot be an empty string."
  }
}

variable "service_proxy_host" {
  type        = string
  description = "Host for service proxy, leave empty if not applicable.  Do not include port"
  default     = ""

  validation {
    condition     = length(var.service_proxy_host) == 0 || can(regex("^service-proxy", var.service_proxy_host))
    error_message = "Must leave service proxy blank or specify a host starting with service-proxy."
  }
}

variable "name_prefix" {
  description = "Prefix to apply to all resource names and hostnames (e.g. \"VPN\",)."
  type        = string
  default     = "VPN"
}

variable "instance_policy_json" {
  description = "JSON IAM policy document that will be attached to the EC2 instance profile."
  type        = string
}