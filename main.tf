resource "random_password" "this" {
  count = var.user_password != null ? 0 : 1

  length      = 16
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
  special     = true
}

resource "scaleway_rdb_instance" "this" {
  engine        = var.engine
  is_ha_cluster = var.ha_enabled
  name          = var.name
  node_type     = var.node_type

  encryption_at_rest = var.enable_encryption
  volume_size_in_gb  = var.volume_size_in_gb
  volume_type        = var.volume_type

  user_name = var.user_name
  password  = var.user_password != null ? var.user_password : random_password.this[0].result

  disable_backup            = var.backup_disabled
  backup_same_region        = var.backup_same_region
  backup_schedule_frequency = var.backup_schedule_frequency
  backup_schedule_retention = var.backup_schedule_retention

  region     = var.region
  project_id = var.project_id
  tags       = var.tags

  dynamic "private_network" {
    for_each = var.private_network != null ? [1] : []
    content {
      pn_id       = try(var.private_network.pn_id, null)
      ip_net      = try(var.private_network.ip_net, null)
      enable_ipam = try(var.private_network.enable_ipam, false)
    }
  }

  settings = var.settings
}

resource "scaleway_rdb_read_replica" "this" {
  count = var.replica_enabled ? 1 : 0

  instance_id = scaleway_rdb_instance.this.id
  region      = var.replica_region != null ? var.replica_region : scaleway_rdb_instance.this.region
  #  direct_access = var.replica_direct_access

  dynamic "private_network" {
    for_each = var.replica_private_network != null ? [1] : []
    content {
      private_network_id = try(var.replica_private_network.pn_id, null)
      service_ip         = try(var.replica_private_network.ip_net, null)
    }
  }
}
