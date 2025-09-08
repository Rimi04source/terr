# =============================================================================
# TERRAFORM VARIABLES FOR PRODUCTION ENVIRONMENT
# =============================================================================

# Core Configuration
aks_cluster_name = "aks-prod-example"
resource_group_name = "rg-aks-prod-example"
location = "East US"
dns_prefix = "aks-prod"
resource_prefix = "prod"

# Networking - Update with your actual subnet and VNet IDs
subnet_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.Network/virtualNetworks/YOUR_VNET/subnets/YOUR_SUBNET"
vnet_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.Network/virtualNetworks/YOUR_VNET"

# GSO Security Requirements
private_cluster_enabled = true
local_account_disabled = true
enable_host_encryption = true
use_existing_disk_encryption_set = false
key_vault_key_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.KeyVault/vaults/YOUR_KEYVAULT/keys/YOUR_KEY"
disk_encryption_set_name = "aks-prod-des"
tls_min_version = "1.2"
api_server_authorized_ip_ranges = ["10.0.0.0/8"]

# Identity Configuration - User Assigned
identity_type = "UserAssigned"
user_assigned_identity_id = ""  # Leave empty to create new identity
user_assigned_identity_name = "aks-prod-identity"
aad_admin_group_object_ids = []

# Node Pool Configuration - System + 3 User Pools
node_pools = {
  system = {
    name                = "systempool"
    mode                = "System"
    vm_size             = "Standard_D4s_v3"
    node_count          = 3
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 6
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    availability_zones  = ["1", "2", "3"]
    enable_spot         = false
    enable_fips         = false
    os_sku              = "Ubuntu"
    os_type             = "Linux"
    node_labels         = { environment = "production", pool = "system" }
    tags                = { purpose = "system", environment = "production" }
    priority            = "Regular"
    eviction_policy     = "Delete"
    spot_max_price      = -1
    max_pods            = 50
    node_taints         = ["CriticalAddonsOnly=true:NoSchedule"]
    pod_subnet_id       = ""
    proximity_placement_group_id = ""
    ultra_ssd_enabled   = false
    windows_profile     = null
    gpu_instance_type   = ""
  }
  general = {
    name                = "generalpool"
    mode                = "User"
    vm_size             = "Standard_D8s_v3"
    node_count          = 3
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    availability_zones  = ["1", "2", "3"]
    enable_spot         = false
    enable_fips         = false
    os_sku              = "Ubuntu"
    os_type             = "Linux"
    node_labels         = { environment = "production", pool = "general", workload = "web" }
    tags                = { purpose = "general-workloads", environment = "production" }
    priority            = "Regular"
    eviction_policy     = "Delete"
    spot_max_price      = -1
    max_pods            = 50
    node_taints         = []
    pod_subnet_id       = ""
    proximity_placement_group_id = ""
    ultra_ssd_enabled   = false
    windows_profile     = null
    gpu_instance_type   = ""
  }
  compute = {
    name                = "computepool"
    mode                = "User"
    vm_size             = "Standard_F16s_v2"
    node_count          = 2
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 8
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    availability_zones  = ["1", "2"]
    enable_spot         = false
    enable_fips         = false
    os_sku              = "Ubuntu"
    os_type             = "Linux"
    node_labels         = { environment = "production", pool = "compute", workload = "cpu-intensive" }
    tags                = { purpose = "compute-workloads", environment = "production" }
    priority            = "Regular"
    eviction_policy     = "Delete"
    spot_max_price      = -1
    max_pods            = 50
    node_taints         = ["workload=compute:NoSchedule"]
    pod_subnet_id       = ""
    proximity_placement_group_id = ""
    ultra_ssd_enabled   = false
    windows_profile     = null
    gpu_instance_type   = ""
  }
  memory = {
    name                = "memorypool"
    mode                = "User"
    vm_size             = "Standard_E8s_v3"
    node_count          = 2
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 6
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    availability_zones  = ["1", "3"]
    enable_spot         = false
    enable_fips         = false
    os_sku              = "Ubuntu"
    os_type             = "Linux"
    node_labels         = { environment = "production", pool = "memory", workload = "memory-intensive" }
    tags                = { purpose = "memory-workloads", environment = "production" }
    priority            = "Regular"
    eviction_policy     = "Delete"
    spot_max_price      = -1
    max_pods            = 50
    node_taints         = ["workload=memory:NoSchedule"]
    pod_subnet_id       = ""
    proximity_placement_group_id = ""
    ultra_ssd_enabled   = false
    windows_profile     = null
    gpu_instance_type   = ""
  }
}

# NAT Gateway - Production
enable_nat_gateway = true
existing_nat_gateway_id = ""
create_nat_gateway = true
nat_gateway_name = "aks-prod-nat-gateway"
nat_gateway_public_ip_count = 2
nat_gateway_sku = "Standard"
public_ip_allocation_method = "Static"
public_ip_sku = "Standard"
nat_gateway_idle_timeout = 10

# Private Endpoints - Production
enable_private_endpoints = true
private_endpoints_subnet_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.Network/virtualNetworks/YOUR_VNET/subnets/YOUR_PE_SUBNET"
create_private_endpoints = true
create_private_dns_zones = true

# Dependency Resource IDs for Private Endpoints
dependency_resource_ids = {
  acr_registry_id           = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.ContainerRegistry/registries/YOUR_ACR"
  key_vault_id             = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.KeyVault/vaults/YOUR_KEYVAULT"
  log_analytics_workspace_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.OperationalInsights/workspaces/YOUR_WORKSPACE"
  storage_account_id       = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.Storage/storageAccounts/YOUR_STORAGE_ACCOUNT"
}

# Service Exposure - LoadBalancer
service_exposure_type = "LoadBalancer"
existing_load_balancer_id = ""
create_internal_load_balancer = true

# Logging Configuration - Both Destinations
enable_diagnostics = true
log_storage_type = "both"
storage_account_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.Storage/storageAccounts/YOUR_STORAGE_ACCOUNT"
log_analytics_workspace_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.OperationalInsights/workspaces/YOUR_WORKSPACE"
log_retention_days = 100

# Backup - Disabled
enable_backup = false

# Security Features - Production
enable_defender_for_containers = true
enable_secret_store_csi_driver = true
enable_secret_rotation = true
secret_rotation_interval = "2m"

# Network Configuration
network_plugin = "azure"
network_policy = "azure"
load_balancer_sku = "Standard"
service_cidr = "10.100.0.0/16"
dns_service_ip = "10.100.0.10"
pod_cidr = "10.244.0.0/16"

# Upgrade Configuration
upgrade_channel = "stable"
enable_node_os_auto_upgrade = true

# Maintenance Window - Production
enable_maintenance_window = true
maintenance_window_config = {
  allowed_days  = ["Saturday", "Sunday"]
  allowed_hours = [2, 3, 4, 5]
  not_allowed   = []
}

# Auto Scaler Profile - Production
enable_auto_scaler_profile = true
auto_scaler_profile = {
  balance_similar_node_groups      = true
  expander                        = "least-waste"
  max_graceful_termination_sec    = 600
  max_node_provisioning_time      = "15m"
  max_unready_nodes              = 3
  max_unready_percentage         = 45
  new_pod_scale_up_delay         = "10s"
  scale_down_delay_after_add     = "10m"
  scale_down_delay_after_delete  = "10s"
  scale_down_delay_after_failure = "3m"
  scan_interval                  = "10s"
  scale_down_unneeded           = "10m"
  scale_down_unready            = "20m"
  scale_down_utilization_threshold = 0.5
}

# Policy Assignments - Production
enable_kubernetes_policy_assignments = true
kubernetes_policy_definition_ids = []
event_record_qps = 5
disable_service_account_token_automount = true

# Features - Production
enable_azure_policy = true
enable_keda = true
enable_vertical_pod_autoscaler = true
enable_workload_identity = true
enable_oidc_issuer = true
enable_image_cleaner = true
image_cleaner_interval_hours = 24
cost_analysis_enabled = true

# Availability Zones - Production
enable_availability_zones = true
cluster_availability_zones = ["1", "2", "3"]
node_pool_zone_distribution = "all"

# Capacity Planning
expected_node_count = "large"
validate_subnet_capacity = true

# Tags
tags = {
  Environment = "production"
  Project     = "aks-example"
  Owner       = "platform-team"
  CostCenter  = "engineering"
  Criticality = "high"
}