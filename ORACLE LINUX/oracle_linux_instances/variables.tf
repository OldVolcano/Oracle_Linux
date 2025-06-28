variable "instance_type" {
  type = string
  validation {
    condition = contains([
      "c5", "c5a", "c5d", "i3", "i3en", "m5", "t3"
    ], element(split(".", var.instance_type), 0))
    error_message = "Instance type must be one of: c5, c5a, c5d, i3, i3en, m5, t3."
  }
}

variable "additional_ebs_volumes" {
  type = list(object({
    device_name = string
    volume_size = number
    volume_type = string
  }))
  default = []
}

variable "key_name" {
  description = "The name of the AWS EC2 Key Pair to allow SSH access"
  type        = string
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security-group IDs to attach to the instance"
}

variable "root_volume_size" {
  type        = number
  description = "Root EBS volume size in GB"
}

variable "root_volume_type" {
  type        = string
  description = "Root EBS volume type (e.g., gp3)"
}

variable "tags" {
  type        = map(string)
  description = "Extra tags"
  default     = {}
}

variable "salt_master_ip" {
  type        = string
  description = "Salt master IP"
}

variable "custom_user_data" {
  type        = string
  description = "Additional user data script content"
  default     = ""
}

variable "vpc_id" {
  type = string
  validation {
    condition     = can(regex("^vpc-.*", var.vpc_id))
    error_message = "vpc_id must start with 'vpc-'"
  }
}

variable "source_dest_check" {
  type        = bool
  default     = true
  description = "Enable or disable source/destination check"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to deploy EC2 into"
}

variable "service_name" {
  type        = string
  description = "Service name"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+[a-z0-9]$", var.service_name))
    error_message = "Invalid service name format"
  }
}

variable "hosted_zone_name" {
  type        = string
  description = "Optional hosted zone name"
  default     = ""
}

variable "hosted_zone_config" {
  type = object({
    name = string
    id   = string
  })
  default = {
    name = ""
    id   = ""
  }
  validation {
    condition = (
      (length(var.hosted_zone_config.name) == 0 && length(var.hosted_zone_config.id) == 0) ||
      (length(var.hosted_zone_config.name) != 0 && length(var.hosted_zone_config.id) != 0)
    )
    error_message = "Both name and id must be set or empty together"
  }
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "Optional cluster name"
  validation {
    condition     = var.cluster_name == "" || can(regex("^[a-z0-9]+$", var.cluster_name))
    error_message = "Cluster name must be lowercase alphanumeric"
  }
}

variable "environment_name" {
  type = string
  validation {
    condition     = length(var.environment_name) > 0
    error_message = "environment_name must not be empty"
  }
}

variable "team_name" {
  type = string
  validation {
    condition     = length(var.team_name) > 0
    error_message = "team_name must not be empty"
  }
}

variable "service_proxy_host" {
  type        = string
  default     = ""
  description = "Optional service proxy host"
  validation {
    condition     = length(var.service_proxy_host) == 0 || can(regex("^service-proxy", var.service_proxy_host))
    error_message = "Must be blank or start with service-proxy"
  }
}

variable "name_prefix" {
  type        = string
  default     = "VPN"
  description = "Prefix for instance name and tags"
}


