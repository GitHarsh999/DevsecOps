variable "instance_name" {
  default = "Monitoring_server" # Names of the instance
}

variable "key_name" {
  default = "terra" # Names of key in aws
}

# ---------- New variables for EKS ----------

variable "region" {
  default = "ap-south-1"
}

variable "cluster_name" {
  default = "hotstar-eks-cluster"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "node_instance_type" {
  default = "t3.micro"
}
