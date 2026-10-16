variable "aws_region" {
  description = "AWS region for the recovery lab"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "Administrator public IPv4 address in CIDR notation"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = "ec2-recovery-lab-key"
}
