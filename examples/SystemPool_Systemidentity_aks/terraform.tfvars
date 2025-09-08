# =============================================================================
# TERRAFORM VARIABLES FOR BASIC DEV ENVIRONMENT
# =============================================================================

# Core Configuration
aks_cluster_name = "aks-dev-example"
resource_group_name = "rg-aks-dev-example"
location = "East US"
dns_prefix = "aks-dev"
resource_prefix = "dev"

# Networking - Update with your actual subnet and VNet IDs
subnet_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.Network/virtualNetworks/YOUR_VNET/subnets/YOUR_SUBNET"

vnet_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.Network/virtualNetworks/YOUR_VNET"

# GSO Security Requirements
private_cluster_enabled = true
local_account_disabled = true
enable_host_encryption = true
use_existing_disk_encryption_set = false
key_vault_key_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.KeyVault/vaults/YOUR_KEYVAULT/keys/YOUR_KEY"
disk_encryption_set_name = "aks-dev-des"
tls_min_version = "1.2"
api_server_authorized_ip_ranges = ["10.0.0.0/8"]

# Identity Configuration - System Assigned
identity_type = "SystemAssigned"
aad_admin_group_object_ids = []

# Node Pool Configuration - System Pool Only
node_pools = {
  system = {
    name                = "systempool"
    mode                = "System"
    vm_size             = "Standard_D2s_v3"
    node_count          = 2
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 4
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    availability_zones  = ["1", "2"]
    enable_spot         = false
    enable_fips         = false
    os_sku              = "Ubuntu"
    os_type             = "Linux"
    node_labels         = { environment = "dev" }
    tags                = { purpose = "system", environment = "dev" }
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
}

# NAT Gateway - Disabled for Dev
enable_nat_gateway = false

# Private Endpoints - Disabled for Dev
enable_private_endpoints = false

# Service Exposure
service_exposure_type = "ClusterIP"

# Logging Configuration - Storage Account Only
enable_diagnostics = true
log_storage_type = "storage_account"
storage_account_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.Storage/storageAccounts/YOUR_STORAGE_ACCOUNT"
log_retention_days = 100

# Backup - Disabled for Dev
enable_backup = false

# Security Features
enable_defender_for_containers = false  # Disabled since no Log Analytics
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

# Maintenance Window
enable_maintenance_window = true
maintenance_window_config = {
  allowed_days  = ["Saturday", "Sunday"]
  allowed_hours = [2, 3, 4, 5]
  not_allowed   = []
}

# Auto Scaler Profile - Disabled
enable_auto_scaler_profile = false

# Features
enable_azure_policy = true
enable_keda = true
enable_vertical_pod_autoscaler = true
enable_workload_identity = true
enable_oidc_issuer = true
enable_image_cleaner = true
image_cleaner_interval_hours = 24
cost_analysis_enabled = true

# Availability Zones
enable_availability_zones = true
cluster_availability_zones = ["1", "2"]
node_pool_zone_distribution = "multiple"

# Capacity Planning
expected_node_count = "small"
validate_subnet_capacity = true

# Tags
tags = {
  Environment = "dev"
  Project     = "aks-example"
  Owner       = "dev-team"
  CostCenter  = "engineering"
}