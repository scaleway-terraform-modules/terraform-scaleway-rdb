output "cluster_certificate" {
  description = "PEM Certificate of the database instance."
  value       = scaleway_rdb_instance.this.certificate
}

output "instance_id" {
  description = "ID of the Database Instance."
  value       = scaleway_rdb_instance.this.id
}

output "load_balancer" {
  description = "List of load balancer endpoints of the database instance."
  value = scaleway_rdb_instance.this.load_balancer
}

output "user_password" {
  description = "Password generated if non were given."
  sensitive = true
  value = try(random_password.this.0.result, null)
}
