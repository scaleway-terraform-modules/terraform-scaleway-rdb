## Instance topology
variable "engine" {
  description = "Database Instance's engine version (e.g. PostgreSQL-11)."
  type        = string
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

## Storage
variable "enable_encryption" {
  description = "Enable encryption at rest for the Database Instance."
  type        = bool
  default     = true
}

variable "volume_type" {
  description = "Type of volume where data are stored (bssd or lssd)."
  type        = string
  default     = "lssd"

  validation {
    condition     = contains(["bssd", "lssd"], var.volume_type)
    error_message = "Volumes can only be one of 'bssd' or 'lssd'."
  }
}

variable "volume_size_in_gb" {
  description = "Volume size (in GB) when volume_type is set to bssd. Must be a multiple of 5000000000."
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
  description = "Password for the first user of the database instance. A random password will be generated if null."
  sensitive   = true
  type        = string
  default     = null
}

## Read replicas
variable "replica_enabled" {
  description = "Whether to create a read replica or not."
  type        = bool
  default     = true
}

variable "replica_private_network" {
  description = "Describes the private network you want to connect to your read replica."
  type = object({
    pn_id  = string
    ip_net = string
  })
  default = null
}

variable "replica_region" {
  description = "Region in which the replica should be created. Ressource will be created in the same region than the master if null."
  type        = string
  default     = null
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
