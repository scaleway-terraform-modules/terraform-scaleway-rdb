# Terraform / Scaleway

## Purpose

This repository is used to manage a Relationnal Database on scaleway using terraform.

## Usage

- Setup the [scaleway provider](https://www.terraform.io/docs/providers/scaleway/index.html) in your tf file.
- Include this module in your tf file. Refer to [documentation](https://www.terraform.io/docs/modules/sources.html#generic-git-repository).

```hcl
module "my_cluster" {
  source  = "scaleway-terraform-modules/rdb/scaleway"
  version = "~> 1.1.0"

  name      = "my-database"
  engine    = "PostgreSQL-15"
  node_type = "db-dev-s"
  user_name = "admin"
}
```

### Write-only password

Use `user_password_wo` instead of `user_password` to avoid storing the password in the Terraform state. Bump `user_password_wo_version` to rotate it.

```hcl
module "my_cluster" {
  source  = "scaleway-terraform-modules/rdb/scaleway"
  version = "~> 1.1.0"

  name      = "my-database"
  engine    = "PostgreSQL-15"
  node_type = "db-dev-s"
  user_name = "admin"

  user_password_wo         = var.database_admin_password
  user_password_wo_version = 1
}
```

### Restoring from a snapshot

Set `snapshot_id` instead of `engine` to create the instance from an existing snapshot.

```hcl
module "my_cluster" {
  source  = "scaleway-terraform-modules/rdb/scaleway"
  version = "~> 1.1.0"

  name        = "my-database"
  snapshot_id = "11111111-1111-1111-1111-111111111111"
  node_type   = "db-dev-s"
  user_name   = "admin"
}
```

### Databases, users, privileges and ACLs

```hcl
module "my_cluster" {
  source  = "scaleway-terraform-modules/rdb/scaleway"
  version = "~> 1.1.0"

  name      = "my-database"
  engine    = "PostgreSQL-15"
  node_type = "db-dev-s"
  user_name = "admin"

  acl_rules = [
    { ip = "1.2.3.4/32", description = "office" }
  ]

  database_names = ["app", "reporting"]

  users = {
    reporting_ro = {
      password = var.reporting_password
    }
  }

  privileges = [
    { user_name = "reporting_ro", database_name = "reporting", permission = "readonly" }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.11 |
| <a name="requirement_random"></a> [random](#requirement_random) | >= 3.4.3 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement_scaleway) | >= 2.68.0 |

## Resources

| Name | Type |
|------|------|
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [scaleway_rdb_acl.this](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_acl) | resource |
| [scaleway_rdb_database.this](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_database) | resource |
| [scaleway_rdb_instance.this](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_instance) | resource |
| [scaleway_rdb_privilege.this](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_privilege) | resource |
| [scaleway_rdb_read_replica.this](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_read_replica) | resource |
| [scaleway_rdb_snapshot.this](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_snapshot) | resource |
| [scaleway_rdb_user.this](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input_name) | Name of the Database Instance | `string` | n/a | yes |
| <a name="input_node_type"></a> [node_type](#input_node_type) | Type of database instance you want to create (e.g. db-dev-s). | `string` | n/a | yes |
| <a name="input_user_name"></a> [user_name](#input_user_name) | Identifier for the first user of the database instance. **Warning** Changing the user_name will recreate the Database Instance. | `string` | n/a | yes |
| <a name="input_acl_rules"></a> [acl_rules](#input_acl_rules) | List of authorized IP rules for the Database Instance's public endpoint. Leave empty (default) to manage ACLs outside this module. | ```list(object({ ip = string description = optional(string) }))``` | `[]` | no |
| <a name="input_backup_disabled"></a> [backup_disabled](#input_backup_disabled) | Disable automated backup for the database instance. | `bool` | `false` | no |
| <a name="input_backup_same_region"></a> [backup_same_region](#input_backup_same_region) | Whether logical backups are stored in the same region as the database instance. | `bool` | `false` | no |
| <a name="input_backup_schedule_frequency"></a> [backup_schedule_frequency](#input_backup_schedule_frequency) | Backup schedule frequency in hours. | `number` | `24` | no |
| <a name="input_backup_schedule_retention"></a> [backup_schedule_retention](#input_backup_schedule_retention) | Backup schedule retention in days. | `number` | `7` | no |
| <a name="input_database_names"></a> [database_names](#input_database_names) | Names of additional databases to create on the Database Instance, beyond the default one created with the instance. | `set(string)` | `[]` | no |
| <a name="input_enable_encryption"></a> [enable_encryption](#input_enable_encryption) | Enable encryption at rest for the Database Instance. | `bool` | `true` | no |
| <a name="input_enable_load_balancer"></a> [enable_load_balancer](#input_enable_load_balancer) | Whether to also provision a public load-balancer endpoint alongside `private_network`. Has no effect when `private_network` is not set, since a public endpoint is already provisioned by default in that case. | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input_engine) | Database Instance's engine version (e.g. PostgreSQL-11). Mutually exclusive with `snapshot_id`; exactly one of the two must be set. | `string` | `null` | no |
| <a name="input_ha_enabled"></a> [ha_enabled](#input_ha_enabled) | Enable or disable high availability for the database instance. | `bool` | `false` | no |
| <a name="input_init_settings"></a> [init_settings](#input_init_settings) | Map of engine settings to be set at database initialisation. Updating this recreates the Database Instance. | `map(string)` | `null` | no |
| <a name="input_private_network"></a> [private_network](#input_private_network) | Describes the private network you want to connect to your cluster. If not set, a public network will be provided. | ```object({ pn_id = string ip_net = optional(string) enable_ipam = optional(bool) })``` | `null` | no |
| <a name="input_privileges"></a> [privileges](#input_privileges) | List of database privilege grants, mapping a user to a database with a permission level. | ```list(object({ user_name = string database_name = string permission = string }))``` | `[]` | no |
| <a name="input_project_id"></a> [project_id](#input_project_id) | ID of the project the instance is associated with. Ressource will be created in the project set at the provider level if null. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input_region) | Region in which the instance should be created. Ressource will be created in the region set at the provider level if null. | `string` | `null` | no |
| <a name="input_replica_enabled"></a> [replica_enabled](#input_replica_enabled) | Whether to create a read replica or not. | `bool` | `true` | no |
| <a name="input_replica_private_network"></a> [replica_private_network](#input_replica_private_network) | Describes the private network you want to connect to your read replica. If not set, the read replica gets a public direct-access endpoint instead. | ```object({ pn_id = string ip_net = optional(string) enable_ipam = optional(bool) })``` | `null` | no |
| <a name="input_replica_region"></a> [replica_region](#input_replica_region) | Region in which the replica should be created. Ressource will be created in the same region than the master if null. | `string` | `null` | no |
| <a name="input_replica_same_zone"></a> [replica_same_zone](#input_replica_same_zone) | Defines whether the replica is created in the same availability zone as the main instance. | `bool` | `null` | no |
| <a name="input_settings"></a> [settings](#input_settings) | Database settings configuration | `map(string)` | `null` | no |
| <a name="input_snapshot_id"></a> [snapshot_id](#input_snapshot_id) | ID of an existing snapshot to restore or create the Database Instance from. Mutually exclusive with `engine`; exactly one of the two must be set. | `string` | `null` | no |
| <a name="input_snapshots"></a> [snapshots](#input_snapshots) | Map of manual snapshots to create for the Database Instance, keyed by snapshot name. | ```map(object({ expires_at = optional(string) }))``` | `{}` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags associated with the server and dedicated ip address. | `list(string)` | `[]` | no |
| <a name="input_user_password"></a> [user_password](#input_user_password) | Password for the first user of the database instance. A random password will be generated if this and `user_password_wo` are both null. Mutually exclusive with `user_password_wo`. | `string` | `null` | no |
| <a name="input_user_password_wo"></a> [user_password_wo](#input_user_password_wo) | Write-only password for the first user of the database instance (never stored in Terraform state). Mutually exclusive with `user_password`. Requires Terraform >= 1.11. To rotate the value, increment `user_password_wo_version`. | `string` | `null` | no |
| <a name="input_user_password_wo_version"></a> [user_password_wo_version](#input_user_password_wo_version) | Version marker for `user_password_wo`. Must be incremented whenever `user_password_wo` changes to trigger the password update. | `number` | `null` | no |
| <a name="input_users"></a> [users](#input_users) | Map of additional database users to create, keyed by user name. Exactly one of `password` or `password_wo` must be set per user. | ```map(object({ password = optional(string) password_wo = optional(string) password_wo_version = optional(number) is_admin = optional(bool, false) }))``` | `{}` | no |
| <a name="input_volume_size_in_gb"></a> [volume_size_in_gb](#input_volume_size_in_gb) | Volume size (in GB) when volume_type is not lssd. | `number` | `null` | no |
| <a name="input_volume_type"></a> [volume_type](#input_volume_type) | Type of volume where data are stored (lssd, sbs_5k or sbs_15k). 'bssd' is accepted for backward compatibility but is a legacy type no longer documented by the provider; prefer sbs_5k or sbs_15k. | `string` | `"lssd"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate"></a> [cluster_certificate](#output_cluster_certificate) | PEM Certificate of the database instance. |
| <a name="output_database_ids"></a> [database_ids](#output_database_ids) | Map of additional database names to their IDs. |
| <a name="output_instance_id"></a> [instance_id](#output_instance_id) | ID of the Database Instance. |
| <a name="output_instance_ip"></a> [instance_ip](#output_instance_ip) | Database instance IP |
| <a name="output_load_balancer"></a> [load_balancer](#output_load_balancer) | List of load balancer endpoints of the database instance. |
| <a name="output_maintenances"></a> [maintenances](#output_maintenances) | List of maintenances events of the Database Instance. |
| <a name="output_organization_id"></a> [organization_id](#output_organization_id) | Organization ID the Database Instance is associated with. |
| <a name="output_privileges"></a> [privileges](#output_privileges) | Map of privilege grants (keyed by `user_name/database_name`) to their effective permission and drift status as reported by the provider. |
| <a name="output_read_replicas"></a> [read_replicas](#output_read_replicas) | List of read replicas of the Database Instance. |
| <a name="output_replicate_pn"></a> [replicate_pn](#output_replicate_pn) | Private network attributes of the read replica. |
| <a name="output_snapshot_ids"></a> [snapshot_ids](#output_snapshot_ids) | Map of manual snapshot names to their IDs. |
| <a name="output_upgradable_versions"></a> [upgradable_versions](#output_upgradable_versions) | List of engine versions the Database Instance can be upgraded to. |
| <a name="output_user_ids"></a> [user_ids](#output_user_ids) | Map of additional user names to their IDs. |
| <a name="output_user_password"></a> [user_password](#output_user_password) | Password generated if non were given. |
<!-- END_TF_DOCS -->

## Authors

Module is maintained with help from [the community](https://github.com/scaleway-terraform-modules/terraform-scaleway-rdb/graphs/contributors).

## License

Mozilla Public License 2.0 Licensed. See [LICENSE](https://github.com/scaleway-terraform-modules/terraform-scaleway-rdb/tree/master/LICENSE) for full details.
