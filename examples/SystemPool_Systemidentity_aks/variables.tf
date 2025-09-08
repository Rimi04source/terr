# =============================================================================
# CORE RESOURCE CONFIGURATION (REQUIRED)
# =============================================================================

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-dev-example"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-aks-dev-example"
}

variable "location" {
  description = "Azure region location"
  type        = string
  default     = "East US"
}

variable "dns_prefix" {
  description = "DNS prefix for AKS cluster"
  type        = string
  default     = "aks-dev"
}

variable "subnet_id" {
  description = "ID of the subnet for AKS node pools"
  type        = string
}



variable "vnet_id" {
  description = "Virtual Network ID where AKS will be deployed"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "dev"
}

# =============================================================================
# GSO SECURITY REQUIREMENTS
# =============================================================================

variable "private_cluster_enabled" {
  description = "Enable private cluster"
  type        = bool
  default     = true
}

variable "local_account_disabled" {
  description = "Disable local accounts"
  type        = bool
  default     = true
}

variable "enable_host_encryption" {
  description = "Enable host-level encryption"
  type        = bool
  default     = true
}

variable "use_existing_disk_encryption_set" {
  description = "Use existing Disk Encryption Set"
  type        = bool
  default     = false
}

variable "existing_disk_encryption_set_id" {
  description = "Existing Disk Encryption Set ID"
  type        = string
  default     = ""
}

variable "key_vault_key_id" {
  description = "Key Vault Key ID for disk encryption"
  type        = string
}

variable "disk_encryption_set_name" {
  description = "Name for new Disk Encryption Set"
  type        = string
  default     = "aks-dev-des"
}

variable "tls_min_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "1.2"
}

variable "api_server_authorized_ip_ranges" {
  description = "Authorized IP ranges for API server access"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# =============================================================================
# IDENTITY CONFIGURATION
# =============================================================================

variable "identity_type" {
  description = "Identity type"
  type        = string
  default     = "SystemAssigned"
}

variable "user_assigned_identity_id" {
  description = "User assigned identity ID"
  type        = string
  default     = ""
}

variable "user_assigned_identity_name" {
  description = "User assigned identity name"
  type        = string
  default     = "aks-identity"
}

variable "aad_admin_group_object_ids" {
  description = "Azure AD admin group object IDs"
  type        = list(string)
  default     = []
}

# =============================================================================
# NODE POOL CONFIGURATION
# =============================================================================

variable "node_pools" {
  description = "Node pool configurations"
  type = map(object({
    name                = string
    mode                = string
    vm_size             = string
    node_count          = number
    enable_auto_scaling = optional(bool, false)
    min_count           = number
    max_count           = number
    os_disk_size_gb     = number
    os_disk_type        = string
    availability_zones  = list(string)
    enable_spot         = optional(bool, false)
    enable_fips         = optional(bool, false)
    os_sku              = string
    os_type             = optional(string, "Linux")
    node_labels         = optional(map(string), {})
    tags                = optional(map(string), {})
    priority            = optional(string, "Regular")
    eviction_policy     = optional(string, "Delete")
    spot_max_price      = optional(number, -1)
    max_pods            = optional(number, 50)
    node_taints         = optional(list(string), [])
    pod_subnet_id       = optional(string, "")
    proximity_placement_group_id = optional(string, "")
    ultra_ssd_enabled   = optional(bool, false)
    windows_profile = optional(object({
      admin_username = string
      admin_password = string
    }), null)
    gpu_instance_type   = optional(string, "")
  }))
  default = {
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
}

# =============================================================================
# NAT GATEWAY CONFIGURATION
# =============================================================================

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = false
}

variable "existing_nat_gateway_id" {
  description = "Existing NAT Gateway ID"
  type        = string
  default     = ""
}

variable "create_nat_gateway" {
  description = "Create new NAT Gateway"
  type        = bool
  default     = false
}

variable "nat_gateway_name" {
  description = "NAT Gateway name"
  type        = string
  default     = "aks-nat-gateway"
}

variable "nat_gateway_public_ip_count" {
  description = "Number of public IPs for NAT Gateway"
  type        = number
  default     = 1
}

variable "nat_gateway_sku" {
  description = "NAT Gateway SKU"
  type        = string
  default     = "Standard"
}

variable "public_ip_allocation_method" {
  description = "Public IP allocation method"
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "Public IP SKU"
  type        = string
  default     = "Standard"
}

variable "nat_gateway_idle_timeout" {
  description = "NAT Gateway idle timeout"
  type        = number
  default     = 10
}

# =============================================================================
# PRIVATE ENDPOINTS CONFIGURATION
# =============================================================================

variable "enable_private_endpoints" {
  description = "Enable private endpoints"
  type        = bool
  default     = false
}

variable "private_endpoints_subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
  default     = ""
}

variable "existing_private_endpoints" {
  description = "Existing private endpoint IDs"
  type = object({
    acr_private_endpoint_id           = optional(string, "")
    key_vault_private_endpoint_id     = optional(string, "")
    log_analytics_private_endpoint_id = optional(string, "")
    storage_private_endpoint_id       = optional(string, "")
  })
  default = {
    acr_private_endpoint_id           = ""
    key_vault_private_endpoint_id     = ""
    log_analytics_private_endpoint_id = ""
    storage_private_endpoint_id       = ""
  }
}

variable "create_private_endpoints" {
  description = "Create new private endpoints"
  type        = bool
  default     = false
}

variable "dependency_resource_ids" {
  description = "Resource IDs of AKS dependencies"
  type = object({
    acr_registry_id           = optional(string, "")
    key_vault_id             = optional(string, "")
    log_analytics_workspace_id = optional(string, "")
    storage_account_id       = optional(string, "")
  })
  default = {
    acr_registry_id           = ""
    key_vault_id             = ""
    log_analytics_workspace_id = ""
    storage_account_id       = ""
  }
}

variable "create_private_dns_zones" {
  description = "Create private DNS zones"
  type        = bool
  default     = false
}

variable "existing_private_dns_zone_ids" {
  description = "Existing private DNS zone IDs"
  type = object({
    acr_dns_zone_id           = optional(string, "")
    key_vault_dns_zone_id     = optional(string, "")
    log_analytics_dns_zone_id = optional(string, "")
    storage_dns_zone_id       = optional(string, "")
  })
  default = {
    acr_dns_zone_id           = ""
    key_vault_dns_zone_id     = ""
    log_analytics_dns_zone_id = ""
    storage_dns_zone_id       = ""
  }
}

# =============================================================================
# SERVICE EXPOSURE
# =============================================================================

variable "service_exposure_type" {
  description = "Service exposure type"
  type        = string
  default     = "ClusterIP"
}

variable "existing_load_balancer_id" {
  description = "Existing Load Balancer ID"
  type        = string
  default     = ""
}

variable "create_internal_load_balancer" {
  description = "Create internal load balancer"
  type        = bool
  default     = false
}

# =============================================================================
# LOGGING CONFIGURATION
# =============================================================================

variable "enable_diagnostics" {
  description = "Enable diagnostics"
  type        = bool
  default     = true
}

variable "log_storage_type" {
  description = "Log storage type"
  type        = string
  default     = "storage_account"
}

variable "storage_account_id" {
  description = "Storage Account ID for logs"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Log retention days"
  type        = number
  default     = 100
}

variable "diagnostic_setting_name" {
  description = "Diagnostic setting name"
  type        = string
  default     = ""
}

variable "diagnostic_log_categories" {
  description = "Diagnostic log categories"
  type        = list(string)
  default = [
    "kube-audit",
    "cluster-autoscaler",
    "kube-controller-manager",
    "kube-scheduler"
  ]
}

variable "diagnostic_metric_categories" {
  description = "Diagnostic metric categories"
  type        = list(string)
  default     = ["AllMetrics"]
}

# =============================================================================
# BACKUP CONFIGURATION
# =============================================================================

variable "enable_backup" {
  description = "Enable backup"
  type        = bool
  default     = false
}

variable "backup_vault_id" {
  description = "Backup vault ID"
  type        = string
  default     = ""
}

variable "backup_policy_id" {
  description = "Backup policy ID"
  type        = string
  default     = ""
}

# =============================================================================
# SECURITY FEATURES
# =============================================================================

variable "enable_defender_for_containers" {
  description = "Enable Microsoft Defender for Containers"
  type        = bool
  default     = false
}

variable "enable_secret_store_csi_driver" {
  description = "Enable Azure Key Vault CSI driver"
  type        = bool
  default     = true
}

variable "enable_secret_rotation" {
  description = "Enable secret rotation"
  type        = bool
  default     = true
}

variable "secret_rotation_interval" {
  description = "Secret rotation interval"
  type        = string
  default     = "2m"
}

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================

variable "network_plugin" {
  description = "Network plugin"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy"
  type        = string
  default     = "azure"
}

variable "load_balancer_sku" {
  description = "Load balancer SKU"
  type        = string
  default     = "Standard"
}

variable "internal_lb_frontend_name" {
  description = "Internal load balancer frontend name"
  type        = string
  default     = "internal-lb-frontend"
}

variable "internal_lb_ip_allocation" {
  description = "Internal load balancer IP allocation"
  type        = string
  default     = "Dynamic"
}

variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "10.100.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP"
  type        = string
  default     = "10.100.0.10"
}

variable "pod_cidr" {
  description = "Pod CIDR"
  type        = string
  default     = "10.244.0.0/16"
}

# =============================================================================
# UPGRADE CONFIGURATION
# =============================================================================

variable "upgrade_channel" {
  description = "Upgrade channel"
  type        = string
  default     = "stable"
}

variable "enable_node_os_auto_upgrade" {
  description = "Enable node OS auto upgrade"
  type        = bool
  default     = true
}

# =============================================================================
# MAINTENANCE WINDOW
# =============================================================================

variable "enable_maintenance_window" {
  description = "Enable maintenance window"
  type        = bool
  default     = true
}

variable "maintenance_window_config" {
  description = "Maintenance window configuration"
  type = object({
    allowed_days  = list(string)
    allowed_hours = list(number)
    not_allowed = optional(list(object({
      start = string
      end   = string
    })), [])
  })
  default = {
    allowed_days  = ["Saturday", "Sunday"]
    allowed_hours = [2, 3, 4, 5]
    not_allowed   = []
  }
}

# =============================================================================
# AUTO SCALER PROFILE
# =============================================================================

variable "enable_auto_scaler_profile" {
  description = "Enable auto scaler profile"
  type        = bool
  default     = false
}

variable "auto_scaler_profile" {
  description = "Auto scaler profile settings"
  type = object({
    balance_similar_node_groups      = optional(bool, false)
    expander                        = optional(string, "random")
    max_graceful_termination_sec    = optional(number, 600)
    max_node_provisioning_time      = optional(string, "15m")
    max_unready_nodes              = optional(number, 3)
    max_unready_percentage         = optional(number, 45)
    new_pod_scale_up_delay         = optional(string, "10s")
    scale_down_delay_after_add     = optional(string, "10m")
    scale_down_delay_after_delete  = optional(string, "10s")
    scale_down_delay_after_failure = optional(string, "3m")
    scan_interval                  = optional(string, "10s")
    scale_down_unneeded           = optional(string, "10m")
    scale_down_unready            = optional(string, "20m")
    scale_down_utilization_threshold = optional(number, 0.5)
  })
  default = {
    balance_similar_node_groups      = false
    expander                        = "random"
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
}

variable "windows_outbound_nat_enabled" {
  description = "Enable outbound NAT for Windows node pools"
  type        = bool
  default     = true
}

# =============================================================================
# POLICY ASSIGNMENTS
# =============================================================================

variable "enable_kubernetes_policy_assignments" {
  description = "Enable Kubernetes policy assignments"
  type        = bool
  default     = false
}

variable "kubernetes_policy_definition_ids" {
  description = "Kubernetes policy definition IDs"
  type        = list(string)
  default     = []
}

variable "event_record_qps" {
  description = "Event record QPS"
  type        = number
  default     = 5
}

variable "disable_service_account_token_automount" {
  description = "Disable service account token automount"
  type        = bool
  default     = true
}

# =============================================================================
# FEATURES
# =============================================================================

variable "enable_azure_policy" {
  description = "Enable Azure Policy"
  type        = bool
  default     = true
}

variable "enable_keda" {
  description = "Enable KEDA"
  type        = bool
  default     = true
}

variable "enable_vertical_pod_autoscaler" {
  description = "Enable Vertical Pod Autoscaler"
  type        = bool
  default     = true
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity"
  type        = bool
  default     = true
}

variable "enable_oidc_issuer" {
  description = "Enable OIDC issuer"
  type        = bool
  default     = true
}

variable "enable_image_cleaner" {
  description = "Enable image cleaner"
  type        = bool
  default     = true
}

variable "image_cleaner_interval_hours" {
  description = "Image cleaner interval hours"
  type        = number
  default     = 24
}

variable "cost_analysis_enabled" {
  description = "Enable cost analysis"
  type        = bool
  default     = true
}

variable "node_pool_snapshot_id" {
  description = "Node pool snapshot ID"
  type        = string
  default     = ""
}

# =============================================================================
# AVAILABILITY ZONES
# =============================================================================

variable "enable_availability_zones" {
  description = "Enable availability zones"
  type        = bool
  default     = true
}

variable "cluster_availability_zones" {
  description = "Cluster availability zones"
  type        = list(string)
  default     = ["1", "2"]
}

variable "node_pool_zone_distribution" {
  description = "Node pool zone distribution"
  type        = string
  default     = "multiple"
}

# =============================================================================
# CAPACITY PLANNING
# =============================================================================

variable "expected_node_count" {
  description = "Expected node count"
  type        = string
  default     = "small"
}

variable "validate_subnet_capacity" {
  description = "Validate subnet capacity"
  type        = bool
  default     = true
}

# =============================================================================
# TAGS
# =============================================================================

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "aks-example"
    Owner       = "dev-team"
  }
}