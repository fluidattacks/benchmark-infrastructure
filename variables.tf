# Define variables
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0866a3c8686eaeeba"  # Replace with a variable or latest AMI
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.large"
}

variable "ssh_key_name" {
  description = "SSH key name"
  type        = string
  default = "benchmark" # Replace with the key name
}

variable "domain_root" {
  description = "Root domain for applications"
  type        = string
  default     = "exmaple.com" # Replace with your root domain
}

variable "initial_allowed_cidr_block" {
  description = "Initial allowed CIDR block for SSH, HTTP, and HTTPS"
  type = list(string)
  default = [ "0.0.0.0/0" ]
}

variable "allowed_cidr_blocks" {
  description = "Allowed CIDR blocks for SSH, HTTP, and HTTPS"
  type        = list(string)
  default     = [
    "104.30.134.27/32",
    "104.30.132.78/32",
  ]
}

variable "allowed_cidr_blocks_ipv6" {
  description = "Allowed CIDR blocks for SSH, HTTP, and HTTPS"
  type        = list(string)
  default     = [
    "2a09:bac0:1001:1cb::/64",
    "2a09:bac0:1000:252::/64"
  ]
}

# AWS Key Pair Resource (Optional)
resource "aws_key_pair" "default" {
  key_name   = var.ssh_key_name
  public_key = file("~/.ssh/benchmark.pub") # Replace with your public key path
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for DNS management"
  type        = string
  default = "value" # Replace with your Cloudflare Zone ID
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  default = "value" # Replace with your Cloudflare API token
}
