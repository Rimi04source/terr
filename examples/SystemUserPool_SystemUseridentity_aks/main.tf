# =============================================================================
# PRODUCTION ENVIRONMENT EXAMPLE
# =============================================================================
# This example creates a production AKS cluster with:
# - User assigned identity
# - System pool + 3 user pools (general, compute, memory)
# - Both storage account and log analytics logging
# - LoadBalancer service exposure (internal)
# - Private endpoints enabled
# - NAT Gateway enabled
# - All production features and GSO compliance

module "systemuserpool_userassignedidentity_aks" {
  source = "../../"

  # Core Configuration
  aks_cluster_name          = var.aks_cluster_name
  resource_group_name       = var.resource_group_name
  location                 = var.location
  dns_prefix               = var.dns_prefix
  subnet_id                = var.subnet_id
  vnet_id                  = var.vnet_id
  resource_prefix          = var.resource_prefix

  # GSO Security Requirements
  private_cluster_enabled = var.private_cluster_enabled
  local_account_disabled  = var.local_account_disabled
  enable_host_encryption  = var.enable_host_encryption
  use_existing_disk_encryption_set = var.use_existing_disk_encryption_set
  existing_disk_encryption_set_id = var.existing_disk_encryption_set_id
  key_vault_key_id = var.key_vault_key_id
  disk_encryption_set_name = var.disk_encryption_set_name
  tls_min_version        = var.tls_min_version
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges

  # Identity Configuration - User Assigned
  identity_type = var.identity_type
  user_assigned_identity_id = var.user_assigned_identity_id
  user_assigned_identity_name = var.user_assigned_identity_name
  aad_admin_group_object_ids = var.aad_admin_group_object_ids

  # Node Pool Configuration - System + 3 User Pools
  node_pools = var.node_pools

  # NAT Gateway Configuration - Production
  enable_nat_gateway = var.enable_nat_gateway
  existing_nat_gateway_id = var.existing_nat_gateway_id
  create_nat_gateway = var.create_nat_gateway
  nat_gateway_name = var.nat_gateway_name
  nat_gateway_public_ip_count = var.nat_gateway_public_ip_count
  nat_gateway_sku = var.nat_gateway_sku
  public_ip_allocation_method = var.public_ip_allocation_method
  public_ip_sku = var.public_ip_sku
  nat_gateway_idle_timeout = var.nat_gateway_idle_timeout

  # Private Endpoints Configuration - Production
  enable_private_endpoints = var.enable_private_endpoints
  private_endpoints_subnet_id = var.private_endpoints_subnet_id
  existing_private_endpoints = var.existing_private_endpoints
  create_private_endpoints = var.create_private_endpoints
  dependency_resource_ids = var.dependency_resource_ids
  create_private_dns_zones = var.create_private_dns_zones
  existing_private_dns_zone_ids = var.existing_private_dns_zone_ids

  # Service Exposure - LoadBalancer
  service_exposure_type = var.service_exposure_type
  existing_load_balancer_id = var.existing_load_balancer_id
  create_internal_load_balancer = var.create_internal_load_balancer

  # Logging Configuration - Both Destinations
  enable_diagnostics = var.enable_diagnostics
  log_storage_type   = var.log_storage_type
  storage_account_id = var.storage_account_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  log_retention_days = var.log_retention_days
  diagnostic_setting_name = var.diagnostic_setting_name
  diagnostic_log_categories = var.diagnostic_log_categories
  diagnostic_metric_categories = var.diagnostic_metric_categories

  # Backup Configuration - Disabled
  enable_backup = var.enable_backup
  backup_vault_id = var.backup_vault_id
  backup_policy_id = var.backup_policy_id

  # Security Features - Production
  enable_defender_for_containers = var.enable_defender_for_containers
  enable_secret_store_csi_driver = var.enable_secret_store_csi_driver
  enable_secret_rotation = var.enable_secret_rotation
  secret_rotation_interval = var.secret_rotation_interval

  # Network Configuration
  network_plugin = var.network_plugin
  network_policy = var.network_policy
  load_balancer_sku = var.load_balancer_sku
  internal_lb_frontend_name = var.internal_lb_frontend_name
  internal_lb_ip_allocation = var.internal_lb_ip_allocation
  service_cidr = var.service_cidr
  dns_service_ip = var.dns_service_ip
  pod_cidr = var.pod_cidr

  # Upgrade Configuration
  upgrade_channel = var.upgrade_channel
  enable_node_os_auto_upgrade = var.enable_node_os_auto_upgrade

  # Maintenance Window - Production
  enable_maintenance_window = var.enable_maintenance_window
  maintenance_window_config = var.maintenance_window_config

  # Auto Scaler Profile - Production
  enable_auto_scaler_profile = var.enable_auto_scaler_profile
  auto_scaler_profile = var.auto_scaler_profile
  windows_outbound_nat_enabled = var.windows_outbound_nat_enabled

  # Policy Assignments - Production
  enable_kubernetes_policy_assignments = var.enable_kubernetes_policy_assignments
  kubernetes_policy_definition_ids = var.kubernetes_policy_definition_ids
  event_record_qps = var.event_record_qps
  disable_service_account_token_automount = var.disable_service_account_token_automount

  # Features - Production
  enable_azure_policy = var.enable_azure_policy
  enable_keda = var.enable_keda
  enable_vertical_pod_autoscaler = var.enable_vertical_pod_autoscaler
  enable_workload_identity = var.enable_workload_identity
  enable_oidc_issuer = var.enable_oidc_issuer
  enable_image_cleaner = var.enable_image_cleaner
  image_cleaner_interval_hours = var.image_cleaner_interval_hours
  cost_analysis_enabled = var.cost_analysis_enabled
  node_pool_snapshot_id = var.node_pool_snapshot_id

  # Availability Zones - Production
  enable_availability_zones = var.enable_availability_zones
  cluster_availability_zones = var.cluster_availability_zones
  node_pool_zone_distribution = var.node_pool_zone_distribution

  # Capacity Planning
  expected_node_count = var.expected_node_count
  validate_subnet_capacity = var.validate_subnet_capacity

  # Tags
  tags = var.tags
}