output "cluster_certificate" {
  description = "PEM Certificate of the database instance."
  value       = scaleway_rdb_instance.this.certificate
}

output "database_ids" {
  description = "Map of additional database names to their IDs."
  value       = { for k, d in scaleway_rdb_database.this : k => d.id }
}

output "instance_id" {
  description = "ID of the Database Instance."
  value       = scaleway_rdb_instance.this.id
}

output "instance_ip" {
  description = "Database instance IP"
  value       = scaleway_rdb_instance.this.private_network[*].ip
}

output "load_balancer" {
  description = "List of load balancer endpoints of the database instance."
  value       = scaleway_rdb_instance.this.load_balancer
}

output "maintenances" {
  description = "List of maintenances events of the Database Instance."
  value       = scaleway_rdb_instance.this.maintenances
}

output "organization_id" {
  description = "Organization ID the Database Instance is associated with."
  value       = scaleway_rdb_instance.this.organization_id
}

output "privileges" {
  description = "Map of privilege grants (keyed by `user_name/database_name`) to their effective permission and drift status as reported by the provider."
  value = {
    for k, p in scaleway_rdb_privilege.this : k => {
      effective_permission = p.effective_permission
      permission_status    = p.permission_status
    }
  }
}

output "read_replicas" {
  description = "List of read replicas of the Database Instance."
  value       = scaleway_rdb_instance.this.read_replicas
}

output "replicate_pn" {
  description = "Private network attributes of the read replica."
  value       = scaleway_rdb_read_replica.this[*].private_network
}

output "snapshot_ids" {
  description = "Map of manual snapshot names to their IDs."
  value       = { for k, s in scaleway_rdb_snapshot.this : k => s.id }
}

output "upgradable_versions" {
  description = "List of engine versions the Database Instance can be upgraded to."
  value       = scaleway_rdb_instance.this.upgradable_versions
}

output "user_ids" {
  description = "Map of additional user names to their IDs."
  value       = { for k, u in scaleway_rdb_user.this : k => u.id }
}

output "user_password" {
  description = "Password generated if non were given."
  sensitive   = true
  value       = try(random_password.this[0].result, null)
}
