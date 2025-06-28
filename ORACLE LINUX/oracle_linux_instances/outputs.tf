output "instance_ids" {
  value = [for instance in aws_instance.oracle_linux_instances : instance.id]
}

output "private_ips" {
  value = [for instance in aws_instance.oracle_linux_instances : instance.private_ip]
}

output "security_group_ids" {
  value = var.security_group_ids
}

