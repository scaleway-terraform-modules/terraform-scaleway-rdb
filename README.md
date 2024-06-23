# Terraform / Scaleway

## Purpose

This repository is used to manage a Relationnal Database on scaleway using terraform.

## Usage

- Setup the [scaleway provider](https://www.terraform.io/docs/providers/scaleway/index.html) in your tf file.
- Include this module in your tf file. Refer to [documentation](https://www.terraform.io/docs/modules/sources.html#generic-git-repository).

```hcl
module "my_cluster" {
  source  = "scaleway-terraform-modules/rdb/scaleway"
  version = "0.0.1"

}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.13 |
| <a name="requirement_random"></a> [random](#requirement_random) | >= 3.4.3 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement_scaleway) | >= 2.3.0 |

## Resources

| Name | Type |
|------|------|
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [scaleway_rdb_instance.this](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_instance) | resource |
| [scaleway_rdb_read_replica.this](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_read_replica) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_engine"></a> [engine](#input_engine) | Database Instance's engine version (e.g. PostgreSQL-11). | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input_name) | Name of the Database Instance | `string` | n/a | yes |
| <a name="input_node_type"></a> [node_type](#input_node_type) | Type of database instance you want to create (e.g. db-dev-s). | `string` | n/a | yes |
| <a name="input_user_name"></a> [user_name](#input_user_name) | Identifier for the first user of the database instance. **Warning** Changing the user_name will recreate the Database Instance. | `string` | n/a | yes |
| <a name="input_backup_disabled"></a> [backup_disabled](#input_backup_disabled) | Disable automated backup for the database instance. | `bool` | `false` | no |
| <a name="input_backup_same_region"></a> [backup_same_region](#input_backup_same_region) | Whether logical backups are stored in the same region as the database instance. | `bool` | `false` | no |
| <a name="input_backup_schedule_frequency"></a> [backup_schedule_frequency](#input_backup_schedule_frequency) | Backup schedule frequency in hours. | `number` | `24` | no |
| <a name="input_backup_schedule_retention"></a> [backup_schedule_retention](#input_backup_schedule_retention) | Backup schedule retention in days. | `number` | `7` | no |
| <a name="input_ha_enabled"></a> [ha_enabled](#input_ha_enabled) | Enable or disable high availability for the database instance. | `bool` | `false` | no |
| <a name="input_private_network"></a> [private_network](#input_private_network) | Describes the private network you want to connect to your cluster. If not set, a public network will be provided. | ```object({ pn_id = string ip_net = optional(string) enable_ipam = optional(bool) })``` | `null` | no |
| <a name="input_project_id"></a> [project_id](#input_project_id) | ID of the project the instance is associated with. Ressource will be created in the project set at the provider level if null. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input_region) | Region in which the instance should be created. Ressource will be created in the region set at the provider level if null. | `string` | `null` | no |
| <a name="input_replica_enabled"></a> [replica_enabled](#input_replica_enabled) | Whether to create a read replica or not. | `bool` | `true` | no |
| <a name="input_replica_private_network"></a> [replica_private_network](#input_replica_private_network) | Describes the private network you want to connect to your read replica. | ```object({ pn_id = string ip_net = string })``` | `null` | no |
| <a name="input_replica_region"></a> [replica_region](#input_replica_region) | Region in which the replica should be created. Ressource will be created in the same region than the master if null. | `string` | `null` | no |
| <a name="input_settings"></a> [settings](#input_settings) | Database settings configuration | `map(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags associated with the server and dedicated ip address. | `list(string)` | `[]` | no |
| <a name="input_user_password"></a> [user_password](#input_user_password) | Password for the first user of the database instance. A random password will be generated if null. | `string` | `null` | no |
| <a name="input_volume_size_in_gb"></a> [volume_size_in_gb](#input_volume_size_in_gb) | Volume size (in GB) when volume_type is set to bssd. Must be a multiple of 5000000000. | `number` | `null` | no |
| <a name="input_volume_type"></a> [volume_type](#input_volume_type) | Type of volume where data are stored (bssd or lssd). | `string` | `"lssd"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate"></a> [cluster_certificate](#output_cluster_certificate) | PEM Certificate of the database instance. |
| <a name="output_instance_id"></a> [instance_id](#output_instance_id) | ID of the Database Instance. |
| <a name="output_instance_ip"></a> [instance_ip](#output_instance_ip) | Database instance IP |
| <a name="output_load_balancer"></a> [load_balancer](#output_load_balancer) | List of load balancer endpoints of the database instance. |
| <a name="output_replicate_pn"></a> [replicate_pn](#output_replicate_pn) | Private network attributes of the read replica. |
| <a name="output_user_password"></a> [user_password](#output_user_password) | Password generated if non were given. |
<!-- END_TF_DOCS -->

## Authors

Module is maintained with help from [the community](https://github.com/scaleway-terraform-modules/terraform-scaleway-domain/graphs/contributors).

## License

Mozilla Public License 2.0 Licensed. See [LICENSE](https://github.com/scaleway-terraform-modules/terraform-scaleway-domain/tree/master/LICENSE) for full details.
