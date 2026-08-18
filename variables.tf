## Instance topology
variable "engine" {
  description = "Database Instance's engine version (e.g. PostgreSQL-11). Mutually exclusive with `snapshot_id`; exactly one of the two must be set."
  type        = string
  default     = null
}

variable "init_settings" {
  description = "Map of engine settings to be set at database initialisation. Updating this recreates the Database Instance."
  type        = map(string)
  default     = null
}

variable "ha_enabled" {
  description = "Enable or disable high availability for the database instance."
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of the Database Instance"
  type        = string
}

variable "node_type" {
  description = "Type of database instance you want to create (e.g. db-dev-s)."
  type        = string
}

variable "settings" {
  description = "Database settings configuration"
  type        = map(string)
  default     = null
}

## Restore
variable "snapshot_id" {
  description = "ID of an existing snapshot to restore or create the Database Instance from. Mutually exclusive with `engine`; exactly one of the two must be set."
  type        = string
  default     = null
}

## Network
variable "private_network" {
  description = "Describes the private network you want to connect to your cluster. If not set, a public network will be provided."
  type = object({
    pn_id       = string
    ip_net      = optional(string)
    enable_ipam = optional(bool)
  })
  default = null
}

variable "enable_load_balancer" {
  description = "Whether to also provision a public load-balancer endpoint alongside `private_network`. Has no effect when `private_network` is not set, since a public endpoint is already provisioned by default in that case."
  type        = bool
  default     = false
}

## Storage
variable "enable_encryption" {
  description = "Enable encryption at rest for the Database Instance."
  type        = bool
  default     = true
}

variable "volume_type" {
  description = "Type of volume where data are stored (lssd, sbs_5k or sbs_15k). 'bssd' is accepted for backward compatibility but is a legacy type no longer documented by the provider; prefer sbs_5k or sbs_15k."
  type        = string
  default     = "lssd"

  validation {
    condition     = contains(["bssd", "lssd", "sbs_5k", "sbs_15k"], var.volume_type)
    error_message = "Volumes can only be one of 'bssd', 'lssd', 'sbs_5k' or 'sbs_15k'."
  }
}

variable "volume_size_in_gb" {
  description = "Volume size (in GB) when volume_type is not lssd."
  type        = number
  default     = null
}

## Backup
variable "backup_disabled" {
  description = "Disable automated backup for the database instance."
  type        = bool
  default     = false
}

variable "backup_same_region" {
  description = "Whether logical backups are stored in the same region as the database instance."
  type        = bool
  default     = false
}

variable "backup_schedule_frequency" {
  description = "Backup schedule frequency in hours."
  type        = number
  default     = 24
}

variable "backup_schedule_retention" {
  description = "Backup schedule retention in days."
  type        = number
  default     = 7
}

## User informations
variable "user_name" {
  description = "Identifier for the first user of the database instance. **Warning** Changing the user_name will recreate the Database Instance."
  type        = string

  validation {
    condition     = can(regex("^[-_a-zA-Z0-9]{1,63}$", var.user_name))
    error_message = "Username can contain up to 63 characters and must start with a letter. Only alphanumeric characters, underscores, and dashes are accepted."
  }
}

variable "user_password" {
  description = "Password for the first user of the database instance. A random password will be generated if this and `user_password_wo` are both null. Mutually exclusive with `user_password_wo`."
  sensitive   = true
  type        = string
  default     = null
}

variable "user_password_wo" {
  description = "Write-only password for the first user of the database instance (never stored in Terraform state). Mutually exclusive with `user_password`. Requires Terraform >= 1.11. To rotate the value, increment `user_password_wo_version`."
  sensitive   = true
  type        = string
  default     = null
}

variable "user_password_wo_version" {
  description = "Version marker for `user_password_wo`. Must be incremented whenever `user_password_wo` changes to trigger the password update."
  type        = number
  default     = null
}

## Access control
variable "acl_rules" {
  description = "List of authorized IP rules for the Database Instance's public endpoint. Leave empty (default) to manage ACLs outside this module."
  type = list(object({
    ip          = string
    description = optional(string)
  }))
  default = []
}

## Databases
variable "database_names" {
  description = "Names of additional databases to create on the Database Instance, beyond the default one created with the instance."
  type        = set(string)
  default     = []
}

## Additional users
variable "users" {
  description = "Map of additional database users to create, keyed by user name. Exactly one of `password` or `password_wo` must be set per user."
  type = map(object({
    password            = optional(string)
    password_wo         = optional(string)
    password_wo_version = optional(number)
    is_admin            = optional(bool, false)
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for name, user in var.users : (user.password != null) != (user.password_wo != null)
    ])
    error_message = "Each user in `users` must set exactly one of `password` or `password_wo`."
  }
}

## Privileges
variable "privileges" {
  description = "List of database privilege grants, mapping a user to a database with a permission level."
  type = list(object({
    user_name     = string
    database_name = string
    permission    = string
  }))
  default = []

  validation {
    condition = alltrue([
      for p in var.privileges : contains(["readonly", "readwrite", "all", "custom", "none"], p.permission)
    ])
    error_message = "Each privilege's `permission` must be one of: readonly, readwrite, all, custom, none."
  }
}

## Read replicas
variable "replica_enabled" {
  description = "Whether to create a read replica or not."
  type        = bool
  default     = true
}

variable "replica_private_network" {
  description = "Describes the private network you want to connect to your read replica. If not set, the read replica gets a public direct-access endpoint instead."
  type = object({
    pn_id       = string
    ip_net      = optional(string)
    enable_ipam = optional(bool)
  })
  default = null
}

variable "replica_region" {
  description = "Region in which the replica should be created. Ressource will be created in the same region than the master if null."
  type        = string
  default     = null
}

variable "replica_same_zone" {
  description = "Defines whether the replica is created in the same availability zone as the main instance."
  type        = bool
  default     = null
}

## Manual snapshots
variable "snapshots" {
  description = "Map of manual snapshots to create for the Database Instance, keyed by snapshot name."
  type = map(object({
    expires_at = optional(string)
  }))
  default = {}
}

## Scaleway tenancy
variable "project_id" {
  description = "ID of the project the instance is associated with. Ressource will be created in the project set at the provider level if null."
  type        = string
  default     = null
}

variable "region" {
  description = "Region in which the instance should be created. Ressource will be created in the region set at the provider level if null."
  type        = string
  default     = null
}

variable "tags" {
  type        = list(string)
  description = "Tags associated with the server and dedicated ip address."
  default     = []
}
