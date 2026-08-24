locals {
  # A snapshot restore fully conflicts with `engine` and all backup settings on the
  # provider side, so those must be omitted (not just defaulted) whenever `snapshot_id` is set.
  restoring_from_snapshot = var.snapshot_id != null

  # Auto-generate a password only when the caller supplied neither `user_password` nor
  # `user_password_wo`; `try()` keeps this null-safe even though `random_password.this`
  # may have `count = 0` on the branch where it isn't used (Terraform evaluates both
  # branches of a conditional).
  generate_user_password = var.user_password == null && var.user_password_wo == null
  instance_password      = var.user_password_wo != null ? null : try(coalesce(var.user_password, random_password.this[0].result), null)

  replica_uses_private_network = var.replica_private_network != null
}

resource "random_password" "this" {
  count = local.generate_user_password ? 1 : 0

  length      = 16
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
  special     = true
}

resource "scaleway_rdb_instance" "this" {
  engine        = var.engine
  snapshot_id   = var.snapshot_id
  init_settings = var.init_settings
  is_ha_cluster = var.ha_enabled
  name          = var.name
  node_type     = var.node_type

  encryption_at_rest = var.enable_encryption
  volume_size_in_gb  = var.volume_size_in_gb
  volume_type        = var.volume_type

  user_name           = var.user_name
  password            = local.instance_password
  password_wo         = var.user_password_wo
  password_wo_version = var.user_password_wo_version

  # `disable_backup`/`backup_same_region`/`backup_schedule_frequency`/`backup_schedule_retention`
  # conflict with `snapshot_id` on the provider side, so they must be left unset (null) during a restore.
  disable_backup            = local.restoring_from_snapshot ? null : var.backup_disabled
  backup_same_region        = local.restoring_from_snapshot ? null : var.backup_same_region
  backup_schedule_frequency = local.restoring_from_snapshot ? null : var.backup_schedule_frequency
  backup_schedule_retention = local.restoring_from_snapshot ? null : var.backup_schedule_retention

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

  dynamic "load_balancer" {
    for_each = var.enable_load_balancer ? [1] : []
    content {}
  }

  settings = var.settings

  lifecycle {
    precondition {
      condition     = var.user_password == null || var.user_password_wo == null
      error_message = "Only one of `user_password` or `user_password_wo` can be set."
    }
    precondition {
      condition     = var.user_password_wo == null || var.user_password_wo_version != null
      error_message = "`user_password_wo_version` must be set when `user_password_wo` is used."
    }
    precondition {
      condition     = (var.engine != null) != (var.snapshot_id != null)
      error_message = "Exactly one of `engine` or `snapshot_id` must be set."
    }
    precondition {
      condition     = var.private_network == null || coalesce(try(var.private_network.enable_ipam, false), false) || try(var.private_network.ip_net, null) != null
      error_message = "`private_network.ip_net` or `private_network.enable_ipam = true` must be set."
    }
  }
}

resource "scaleway_rdb_read_replica" "this" {
  count = var.replica_enabled ? 1 : 0

  instance_id = scaleway_rdb_instance.this.id
  region      = var.replica_region != null ? var.replica_region : scaleway_rdb_instance.this.region
  same_zone   = var.replica_same_zone

  dynamic "direct_access" {
    for_each = local.replica_uses_private_network ? [] : [1]
    content {}
  }

  dynamic "private_network" {
    for_each = local.replica_uses_private_network ? [1] : []
    content {
      private_network_id = try(var.replica_private_network.pn_id, null)
      service_ip         = try(var.replica_private_network.ip_net, null)
      enable_ipam        = try(var.replica_private_network.enable_ipam, null)
    }
  }

  lifecycle {
    precondition {
      condition     = !local.replica_uses_private_network || coalesce(try(var.replica_private_network.enable_ipam, false), false) || try(var.replica_private_network.ip_net, null) != null
      error_message = "`replica_private_network.ip_net` or `replica_private_network.enable_ipam = true` must be set."
    }
  }
}

resource "scaleway_rdb_acl" "this" {
  count       = length(var.acl_rules) > 0 ? 1 : 0
  instance_id = scaleway_rdb_instance.this.id
  region      = scaleway_rdb_instance.this.region

  dynamic "acl_rules" {
    for_each = var.acl_rules
    content {
      ip          = acl_rules.value.ip
      description = acl_rules.value.description
    }
  }
}

resource "scaleway_rdb_database" "this" {
  for_each = var.database_names

  instance_id = scaleway_rdb_instance.this.id
  region      = scaleway_rdb_instance.this.region
  name        = each.value
}

resource "scaleway_rdb_user" "this" {
  # `var.users` is sensitive, so its keys must be extracted with `nonsensitive()`
  # before being used as a for_each argument (Terraform forbids sensitive for_each keys).
  for_each = toset(nonsensitive(keys(var.users)))

  instance_id         = scaleway_rdb_instance.this.id
  region              = scaleway_rdb_instance.this.region
  name                = each.value
  password            = var.users[each.value].password
  password_wo         = var.users[each.value].password_wo
  password_wo_version = var.users[each.value].password_wo_version
  is_admin            = var.users[each.value].is_admin
}

resource "scaleway_rdb_privilege" "this" {
  for_each = { for p in var.privileges : "${p.user_name}/${p.database_name}" => p }

  instance_id   = scaleway_rdb_instance.this.id
  region        = scaleway_rdb_instance.this.region
  user_name     = each.value.user_name
  database_name = each.value.database_name
  permission    = each.value.permission

  depends_on = [scaleway_rdb_database.this, scaleway_rdb_user.this]
}

resource "scaleway_rdb_snapshot" "this" {
  for_each = var.snapshots

  name        = each.key
  instance_id = scaleway_rdb_instance.this.id
  region      = scaleway_rdb_instance.this.region
  expires_at  = each.value.expires_at
}
