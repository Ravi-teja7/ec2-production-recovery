output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.production.id
}

output "public_ip" {
  description = "EC2 public IPv4 address"
  value       = aws_instance.production.public_ip
}

output "application_url" {
  description = "Sample web application URL"
  value       = "http://${aws_instance.production.public_ip}"
}

output "root_volume_id" {
  description = "Root EBS volume ID for backups"
  value       = aws_instance.production.root_block_device[0].volume_id
}

output "recovery_alarm_name" {
  description = "CloudWatch system recovery alarm"
  value       = aws_cloudwatch_metric_alarm.system_recovery.alarm_name
}
