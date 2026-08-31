output "public_ip" {
  value = "Your Ec2 IP is : ${aws_instance.Monitoring_server.public_ip}"
}

# ---------- New outputs for EKS ----------

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
