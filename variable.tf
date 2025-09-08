# =============================================================================
# CORE RESOURCE CONFIGURATION (REQUIRED)
# =============================================================================

variable "aks_cluster_name" {
  description = "[REQUIRED] Name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "[REQUIRED] Name of the resource group"
  type        = string
}

variable "location" {
  description = "[REQUIRED] Azure region location"
  type        = string
}

variable "subnet_id" {
  description = "[REQUIRED] ID of the subnet for AKS node pools"
  type        = string
}



# =============================================================================
# CORE RESOURCE CONFIGURATION (OPTIONAL)
# =============================================================================

variable "resource_prefix" {
  description = "[OPTIONAL] Prefix for all resource names"
  type        = string
  default     = null
}

# =============================================================================
# AKS CLUSTER CONFIGURATION (OPTIONAL)
# =============================================================================

variable "dns_prefix" {
  description = "[OPTIONAL] DNS prefix for AKS cluster"
  type        = string
  default     = "aks-cluster"
}

variable "private_cluster_enabled" {
  description = "[REQUIRED] Enable private cluster for enhanced security and network isolation (GSO Policy EP_AKS_100 & EP_AKS_101)"
  type        = bool
  default     = true

  # GSO Policy EP_AKS_100: Azure Kubernetes Service Clusters should use private clusters and API access restricted to ADP network
  validation {
    condition     = var.private_cluster_enabled == true
    error_message = "GSO Policy EP_AKS_100: Azure Kubernetes Service Clusters should use private clusters and API access restricted to ADP network."
  }

  # GSO Policy EP_AKS_101: Azure Container Services managed clusters must not be exposed to the internet
  validation {
    condition     = var.private_cluster_enabled == true
    error_message = "GSO Policy EP_AKS_101: Azure Container Services managed clusters must not be exposed to the internet."
  }
}

variable "local_account_disabled" {
  description = "[REQUIRED] Disable local accounts for AKS cluster (GSO Policy IP_AKS_101)"
  type        = bool
  default     = true

  # GSO Policy IP_AKS_101: Azure Kubernetes Service Clusters should have local authentication methods disabled
  validation {
    condition     = var.local_account_disabled == true
    error_message = "GSO Policy IP_AKS_101: Azure Kubernetes Service Clusters should have local authentication methods disabled."
  }
}

variable "use_existing_disk_encryption_set" {
  description = "[REQUIRED] Use existing Disk Encryption Set? If false, new DES will be created"
  type        = bool
  default     = false
}

variable "existing_disk_encryption_set_id" {
  description = "[OPTIONAL] Existing Disk Encryption Set ID (only used if use_existing_disk_encryption_set = true)"
  type        = string
  default     = ""
}

variable "key_vault_key_id" {
  description = "[OPTIONAL] Key Vault Key ID for new DES creation (only used if use_existing_disk_encryption_set = false)"
  type        = string
  default     = ""
}

variable "disk_encryption_set_name" {
  description = "[OPTIONAL] Name for new Disk Encryption Set (only used if creating new)"
  type        = string
  default     = "aks-des"
}

variable "enable_host_encryption" {
  description = "[REQUIRED] Enable host-level encryption for temp disks and cache (GSO Policy EN_AKS_101)"
  type        = bool
  default     = true

  # GSO Policy EN_AKS_101: Temporary disks and cache for agent node pools in Azure Kubernetes Service clusters should be encrypted at host
  # validation {
  #   condition     = var.enable_host_encryption == true
  #   error_message = "GSO Policy EN_AKS_101: Temporary disks and cache for agent node pools in Azure Kubernetes Service clusters should be encrypted at host."
  # }
}

# =============================================================================
# IDENTITY CONFIGURATION
# =============================================================================
# SystemAssigned identity is automatically created by AKS
# UserAssigned identity can be existing or newly created

# =============================================================================
# IDENTITY CONFIGURATION - SIMPLIFIED LOGIC
# =============================================================================
# Simple choice: SystemAssigned (Azure creates) or UserAssigned (you provide/create)

variable "identity_type" {
  description = "[REQUIRED] Choose identity type: SystemAssigned or UserAssigned"
  type        = string
  default     = "SystemAssigned"
}

# Only needed if identity_type = "UserAssigned"
variable "user_assigned_identity_id" {
  description = "[OPTIONAL] If UserAssigned: provide existing identity ID, or leave empty to create new one"
  type        = string
  default     = ""
}

variable "user_assigned_identity_name" {
  description = "[OPTIONAL] Name for new UserAssigned identity (only used if creating new)"
  type        = string
  default     = "aks-identity"
}

# RBAC Configuration
variable "aad_admin_group_object_ids" {
  description = "[REQUIRED] List of Azure AD group IDs for cluster-admin access (GSO Policy IP_AKS_102)"
  type        = list(string)
  default     = []

  # GSO Policy IP_AKS_102: Azure Kubernetes Service Clusters should enable Azure Active Directory integration
  # validation {
  #   condition     = length(var.aad_admin_group_object_ids) > 0
  #   error_message = "GSO Policy IP_AKS_102: Azure Kubernetes Service Clusters should enable Azure Active Directory integration (admin group IDs required)."
  # }

  # GSO Least Privilege Policy: Apply principles of Least Privilege in all cases, using ROLES
  validation {
    condition     = length(var.aad_admin_group_object_ids) <= 5
    error_message = "GSO Least Privilege Policy: Limit cluster-admin access to minimum required AAD groups (maximum 5 groups recommended)."
  }
}

# Network Configuration
variable "vnet_id" {
  description = "[REQUIRED] Virtual Network ID where AKS will be deployed"
  type        = string
}

# =============================================================================
# NAT GATEWAY CONFIGURATION
# =============================================================================
# NAT Gateway is critical for private AKS clusters to enable outbound internet access
# for container image pulls, updates, and Azure service communication

variable "enable_nat_gateway" {
  description = "[REQUIRED] Enable NAT Gateway for outbound internet access (required for private clusters)"
  type        = bool
  default     = true

  validation {
    condition     = var.private_cluster_enabled == false || var.enable_nat_gateway == true
    error_message = "NAT Gateway is required for private AKS clusters to enable outbound internet access for container pulls and updates."
  }
}

variable "existing_nat_gateway_id" {
  description = "[OPTIONAL] Existing NAT Gateway ID to use (if not provided, new NAT Gateway will be created)"
  type        = string
  default     = ""
}

variable "create_nat_gateway" {
  description = "[OPTIONAL] Create new NAT Gateway if no existing ID provided (only used if enable_nat_gateway = true)"
  type        = bool
  default     = true
}

variable "nat_gateway_name" {
  description = "[OPTIONAL] Name for new NAT Gateway (only used if creating new NAT Gateway)"
  type        = string
  default     = "aks-nat-gateway"
}

variable "nat_gateway_public_ip_count" {
  description = "[OPTIONAL] Number of public IPs to create for NAT Gateway"
  type        = number
  default     = 1
}

variable "nat_gateway_sku" {
  description = "[OPTIONAL] NAT Gateway SKU (Azure only supports Standard)"
  type        = string
  default     = "Standard"
}

variable "public_ip_allocation_method" {
  description = "[OPTIONAL] Public IP allocation method for NAT Gateway (must be Static)"
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "[OPTIONAL] Public IP SKU for NAT Gateway (must be Standard)"
  type        = string
  default     = "Standard"
}

variable "nat_gateway_idle_timeout" {
  description = "[OPTIONAL] Idle timeout for NAT Gateway in minutes"
  type        = number
  default     = 10
}

# =============================================================================
# PRIVATE ENDPOINTS CONFIGURATION
# =============================================================================
# Private Endpoints are critical for GSO compliance and zero-trust architecture
# Ensures all AKS dependencies are accessed privately without internet traffic

variable "enable_private_endpoints" {
  description = "[REQUIRED] Enable private endpoints for AKS dependencies (ACR, Key Vault, Log Analytics, Storage)"
  type        = bool
  default     = true

  validation {
    condition     = var.private_cluster_enabled == false || var.enable_private_endpoints == true
    error_message = "Private endpoints are required for private AKS clusters to maintain zero-trust architecture and GSO compliance."
  }
}

variable "private_endpoints_subnet_id" {
  description = "[OPTIONAL] Subnet ID for private endpoints (should be different from AKS subnet)"
  type        = string
  default     = ""
}

variable "existing_private_endpoints" {
  description = "[OPTIONAL] Existing private endpoint IDs for AKS dependencies"
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
  description = "[OPTIONAL] Create new private endpoints if no existing IDs provided"
  type        = bool
  default     = true
}

variable "dependency_resource_ids" {
  description = "[OPTIONAL] Resource IDs of AKS dependencies for private endpoint creation"
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
  description = "[OPTIONAL] Create private DNS zones for private endpoints"
  type        = bool
  default     = true
}

variable "existing_private_dns_zone_ids" {
  description = "[OPTIONAL] Existing private DNS zone IDs"
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
# SMART CLUSTER PROFILES
# =============================================================================
# Predefined configurations for common use cases



variable "expected_node_count" {
  description = "[OPTIONAL] Expected number of nodes for intelligent scaling configuration"
  type        = string
  default     = "small"
}

variable "validate_subnet_capacity" {
  description = "[OPTIONAL] Validate subnet has sufficient IP addresses for expected nodes"
  type        = bool
  default     = true
}

# =============================================================================
# SERVICE EXPOSURE CONFIGURATION
# =============================================================================
# Configure how services will be exposed from the AKS cluster

variable "service_exposure_type" {
  description = "[OPTIONAL] How to expose services: ClusterIP, NodePort, or LoadBalancer"
  type        = string
  default     = "ClusterIP"

  # GSO API Gateway Policy: Use an API gateway attached to GWSE edge for exposing custom APIs or Internet services
  validation {
    condition     = var.service_exposure_type != "NodePort"
    error_message = "GSO API Gateway Policy: Use an API gateway attached to GWSE edge for exposing custom APIs or Internet services. NodePort services expose direct internet access which bypasses required API Gateway controls."
  }
}

variable "existing_load_balancer_id" {
  description = "[OPTIONAL] Existing Load Balancer ID to attach (must be internal - GSO Policy IP_AKS_103)"
  type        = string
  default     = ""
}

variable "create_internal_load_balancer" {
  description = "[OPTIONAL] Create internal load balancer if no existing LB provided (only used if service_exposure_type = LoadBalancer)"
  type        = bool
  default     = true
}

# Node Pool Configuration
variable "node_pools" {
  description = "Map of node pool configurations (at least one system pool required)"
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
    # Enhanced scaling and placement options
    priority            = optional(string, "Regular")
    eviction_policy     = optional(string, "Delete")
    spot_max_price      = optional(number, -1)
    max_pods            = optional(number, 30)
    node_taints         = optional(list(string), [])
    pod_subnet_id       = optional(string, "")
    proximity_placement_group_id = optional(string, "")
    ultra_ssd_enabled   = optional(bool, false)
    # Windows-specific options
    windows_profile = optional(object({
      admin_username = string
      admin_password = string
    }), null)
    # GPU options
    gpu_instance_type   = optional(string, "")
  }))
  default = {
    system = {
      name                = "systempool"
      mode                = "System"
      vm_size             = "Standard_D4s_v3"
      node_count          = 2
      enable_auto_scaling = false
      min_count           = 2
      max_count           = 3
      os_disk_size_gb     = 128
      os_disk_type        = "Managed"
      availability_zones  = ["1"]
      enable_spot         = false
      enable_fips         = false
      os_sku              = "Ubuntu"
      os_type             = "Linux"
      node_labels         = {}
      tags                = { "purpose" = "system" }
      priority            = "Regular"
      eviction_policy     = "Delete"
      spot_max_price      = -1
      max_pods            = 30
      node_taints         = []
      pod_subnet_id       = ""
      proximity_placement_group_id = ""
      ultra_ssd_enabled   = false
      windows_profile     = null
      gpu_instance_type   = ""
    }
  }

  validation {
    condition     = length(var.node_pools) > 0
    error_message = "At least one node pool is required for AKS cluster."
  }

  # GSO Policy EN_AKS_100: Operating systems and data disks in Azure Kubernetes Service clusters should be encrypted by customer-managed keys
  validation {
    condition = alltrue([
      for pool in var.node_pools :
      pool.os_disk_type == "Managed"
    ])
    error_message = "GSO Policy EN_AKS_100: Operating systems and data disks in Azure Kubernetes Service clusters should be encrypted by customer-managed keys (requires managed disks)."
  }

  # VM Size compatibility with features validation
  validation {
    condition = alltrue([
      for pool in var.node_pools :
      var.enable_host_encryption == false || can(regex("^Standard_(D|E|F|M)[0-9]+[a-z]*s_v[3-5]$", pool.vm_size))
    ])
    error_message = "Host encryption requires VM sizes that support encryption at host (D, E, F, M series v3+ with 's' suffix)."
  }

  validation {
    condition = alltrue([
      for pool in var.node_pools :
      pool.ultra_ssd_enabled == false || can(regex("^Standard_(D|E|F|M)[0-9]+[a-z]*s_v[3-5]$", pool.vm_size))
    ])
    error_message = "Ultra SSD requires premium storage capable VM sizes (D, E, F, M series v3+ with 's' suffix)."
  }

  validation {
    condition = alltrue([
      for pool in var.node_pools :
      pool.gpu_instance_type == "" || can(regex("^Standard_N[CV][0-9]+[a-z]*s?_v[2-4]$", pool.vm_size))
    ])
    error_message = "GPU workloads require N-series VM sizes (NC, ND, NV series)."
  }

  # Resource quota validation
  validation {
    condition = alltrue([
      for pool in var.node_pools :
      pool.max_count <= 1000
    ])
    error_message = "Maximum node count per pool cannot exceed 1000 (Azure AKS limit)."
  }

  validation {
    condition = sum([for pool in var.node_pools : pool.max_count]) <= 5000
    error_message = "Total maximum nodes across all pools cannot exceed 5000 (Azure AKS cluster limit)."
  }

  validation {
    condition = alltrue([
      for pool in var.node_pools :
      pool.max_pods >= 50
    ])
    error_message = "Max pods per node must be at least 50 for production workloads."
  }
}

# =============================================================================
# HIGH AVAILABILITY CONFIGURATION
# =============================================================================
# Configure availability zones for cluster and node pool distribution

variable "enable_availability_zones" {
  description = "[OPTIONAL] Enable availability zones for high availability"
  type        = bool
  default     = true
}

variable "cluster_availability_zones" {
  description = "[OPTIONAL] Availability zones for AKS control plane (if supported in region)"
  type        = list(string)
  default     = ["1", "2", "3"]

  validation {
    condition = alltrue([
      for zone in var.cluster_availability_zones :
      can(regex("^[1-3]$", zone))
    ])
    error_message = "Availability zones must be valid zone numbers: 1, 2, or 3."
  }
}

variable "node_pool_zone_distribution" {
  description = "[OPTIONAL] How to distribute node pools across zones: single, multiple, or all"
  type        = string
  default     = "all"

  validation {
    condition     = contains(["single", "multiple", "all"], var.node_pool_zone_distribution)
    error_message = "Node pool zone distribution must be one of: single, multiple, all."
  }
}

# Azure Policy Configuration
variable "enable_azure_policy" {
  description = "[REQUIRED] Enable Azure Policy add-on for governance and compliance management"
  type        = bool
  default     = true

  validation {
    condition     = var.enable_azure_policy == true
    error_message = "Governance Requirement: Azure Policy enforces organizational standards and assesses compliance at scale."
  }
}

# Upgrade Configuration
variable "upgrade_channel" {
  description = "[REQUIRED] AKS upgrade channel for latest version updates (GSO Policy IP_AKS_104)"
  type        = string
  default     = "stable"

  # GSO Policy IP_AKS_104: Azure Kubernetes Service Clusters must be updated to the latest version
  validation {
    condition     = contains(["patch", "stable", "rapid"], var.upgrade_channel)
    error_message = "GSO Policy IP_AKS_104: Azure Kubernetes Service Clusters must be updated to the latest version (upgrade channel cannot be 'none')."
  }

  # GSO Compliance: Ensure always latest version policy
  validation {
    condition     = var.upgrade_channel != "none"
    error_message = "GSO Policy IP_AKS_104: Clusters must always be on latest version - 'none' channel is prohibited."
  }
}

variable "enable_node_os_auto_upgrade" {
  description = "[OPTIONAL] Enable node OS auto-upgrade"
  type        = bool
  default     = true
}



# =============================================================================
# NODE MAINTENANCE CONFIGURATION
# =============================================================================
# Configure maintenance windows for node updates and upgrades

variable "enable_maintenance_window" {
  description = "[REQUIRED] Enable maintenance window configuration for controlled upgrades (GSO Policy IP_AKS_104)"
  type        = bool
  default     = true

  # GSO Policy IP_AKS_104: Clusters must be updated but with user-controlled timing to avoid operational risks
  validation {
    condition     = var.enable_maintenance_window == true
    error_message = "GSO Policy IP_AKS_104: Maintenance windows are mandatory to control upgrade timing and prevent operational disruption."
  }
}

variable "maintenance_window_config" {
  description = "[OPTIONAL] Maintenance window configuration"
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

  validation {
    condition = alltrue([
      for day in var.maintenance_window_config.allowed_days :
      contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], day)
    ])
    error_message = "Allowed days must be valid day names (Monday, Tuesday, etc.)."
  }

  validation {
    condition = alltrue([
      for hour in var.maintenance_window_config.allowed_hours :
      hour >= 0 && hour <= 23
    ])
    error_message = "Allowed hours must be between 0 and 23."
  }
}

# =============================================================================
# LOG STORAGE CONFIGURATION
# =============================================================================
# Configure where AKS diagnostic logs will be stored

variable "log_storage_type" {
  description = "[REQUIRED] Log storage strategy: log_analytics, storage_account, or both"
  type        = string
  default     = "both"

  validation {
    condition     = contains(["log_analytics", "storage_account", "both"], var.log_storage_type)
    error_message = "Log storage type must be one of: log_analytics, storage_account, both."
  }
}

variable "log_analytics_workspace_id" {
  description = "[OPTIONAL] Log Analytics Workspace ID for real-time monitoring (required if log_storage_type = log_analytics or both)"
  type        = string
  default     = ""
}

variable "storage_account_id" {
  description = "[OPTIONAL] Storage Account ID for long-term log retention (required if log_storage_type = storage_account or both)"
  type        = string
  default     = ""
}

variable "enable_auto_scaler_profile" {
  description = "[OPTIONAL] Enable custom cluster autoscaler profile configuration (if false, Azure uses default settings)"
  type        = bool
  default     = false
}

variable "windows_outbound_nat_enabled" {
  description = "[OPTIONAL] Enable outbound NAT for Windows node pools"
  type        = bool
  default     = true
}

variable "enable_kubernetes_policy_assignments" {
  description = "[OPTIONAL] Enable Azure Policy assignments for Kubernetes security enforcement"
  type        = bool
  default     = false
}

variable "kubernetes_policy_definition_ids" {
  description = "[OPTIONAL] List of Azure Policy definition IDs to assign (only used if enable_kubernetes_policy_assignments = true)"
  type        = list(string)
  default     = []

  validation {
    condition = var.enable_kubernetes_policy_assignments == false || length(var.kubernetes_policy_definition_ids) > 0
    error_message = "When enable_kubernetes_policy_assignments is true, kubernetes_policy_definition_ids must be provided."
  }
}

# CIS/GSO Security Controls
variable "event_record_qps" {
  description = "[OPTIONAL] Event record QPS for DoS protection (CIS: eventRecordQPS should be set to 5 or greater)"
  type        = number
  default     = 5
}

variable "disable_service_account_token_automount" {
  description = "[OPTIONAL] Disable automountServiceAccountToken for default service accounts (CIS compliance)"
  type        = bool
  default     = true
}

# =============================================================================
# ENTERPRISE SECURITY & COMPLIANCE
# =============================================================================

variable "enable_defender_for_containers" {
  description = "[REQUIRED] Enable Microsoft Defender for Containers (GSO Runtime Security Policy)"
  type        = bool
  default     = true

  # GSO Runtime Security Policy: Runtime environment must undergo security monitoring for anomaly and suspicious behavior detection and/or prevention
  # Note: Defender requires Log Analytics workspace - can be disabled if no workspace available
  validation {
    condition     = var.enable_defender_for_containers == true || var.log_analytics_workspace_id == ""
    error_message = "GSO Runtime Security Policy: Runtime environment must undergo security monitoring. Defender for Containers can only be disabled if no Log Analytics workspace is available."
  }
}

variable "enable_secret_store_csi_driver" {
  description = "[REQUIRED] Enable Azure Key Vault CSI driver for secret management (GSO Secrets Management Policy)"
  type        = bool
  default     = true

  # GSO Secrets Management Policy: Secrets must be managed, stored, and rotated in accordance with Encryption Standard
  validation {
    condition     = var.enable_secret_store_csi_driver == true
    error_message = "GSO Secrets Management Policy: Secrets (API keys, service credentials, certificates, etc) must be managed, stored, and rotated in accordance with Encryption Standard."
  }
}

variable "enable_workload_identity" {
  description = "[OPTIONAL] Enable Workload Identity for pod-level authentication"
  type        = bool
  default     = true
}

variable "enable_oidc_issuer" {
  description = "[OPTIONAL] Enable OIDC issuer for Workload Identity"
  type        = bool
  default     = true
}



variable "enable_image_cleaner" {
  description = "[OPTIONAL] Enable image cleaner to remove unused container images"
  type        = bool
  default     = true
}

variable "image_cleaner_interval_hours" {
  description = "[OPTIONAL] Image cleaner interval in hours"
  type        = number
  default     = 24
}

# =============================================================================
# ENTERPRISE NETWORKING
# =============================================================================



# =============================================================================
# ENTERPRISE BACKUP & DISASTER RECOVERY
# =============================================================================

variable "enable_backup" {
  description = "[OPTIONAL] Enable Azure Backup for AKS cluster"
  type        = bool
  default     = true
}

variable "backup_vault_id" {
  description = "[OPTIONAL] Azure Backup Vault ID for cluster backup"
  type        = string
  default     = ""
}

variable "backup_policy_id" {
  description = "[OPTIONAL] Backup policy ID for AKS backup"
  type        = string
  default     = ""
}

# =============================================================================
# ENTERPRISE COST MANAGEMENT
# =============================================================================

variable "cost_analysis_enabled" {
  description = "[OPTIONAL] Enable cost analysis and optimization"
  type        = bool
  default     = true
}

variable "node_pool_snapshot_id" {
  description = "[OPTIONAL] Node pool snapshot ID for faster scaling"
  type        = string
  default     = ""
}

# =============================================================================
# DATA IN TRANSIT ENCRYPTION (GSO COMPLIANCE)
# =============================================================================

variable "tls_min_version" {
  description = "[REQUIRED] Minimum TLS version for HTTPS-only access (GSO Policy IP_AKS_104)"
  type        = string
  default     = "1.2"

  # GSO Policy IP_AKS_104: Kubernetes clusters should be accessible only over HTTPS
  validation {
    condition     = contains(["1.2", "1.3"], var.tls_min_version)
    error_message = "GSO Policy IP_AKS_104: Kubernetes clusters should be accessible only over HTTPS (TLS 1.2 or 1.3 required)."
  }
}

variable "api_server_authorized_ip_ranges" {
  description = "[REQUIRED] Authorized ADP network IP ranges for API server access (GSO Policy EP_AKS_100)"
  type        = list(string)
  default     = []

  # GSO Policy EP_AKS_100: Azure Kubernetes Service Clusters should use private clusters and API access restricted to ADP network
  validation {
    condition     = length(var.api_server_authorized_ip_ranges) > 0
    error_message = "GSO Policy EP_AKS_100: Azure Kubernetes Service Clusters should use private clusters and API access restricted to ADP network."
  }
}

# =============================================================================
# NETWORK CONFIGURATION VARIABLES
# =============================================================================

variable "network_plugin" {
  description = "[REQUIRED] Network plugin for AKS cluster (GSO Policy IP_AKS_105)"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be either azure or kubenet."
  }

  # GSO Policy IP_AKS_105: Use network policies to isolate traffic in your cluster network
  validation {
    condition     = var.network_plugin == "azure"
    error_message = "GSO Policy IP_AKS_105: Use network policies to isolate traffic in your cluster network (Azure CNI required for network policy support)."
  }
}

variable "network_policy" {
  description = "[REQUIRED] Network policy engine for traffic isolation (GSO Policy IP_AKS_105)"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "calico"], var.network_policy)
    error_message = "Network policy must be either azure or calico."
  }

  validation {
    condition     = var.network_policy != ""
    error_message = "GSO Policy IP_AKS_105: Network policy engine must be configured for traffic isolation."
  }
}

variable "load_balancer_sku" {
  description = "[OPTIONAL] Load balancer SKU for enterprise networking"
  type        = string
  default     = "Standard"
}

variable "internal_lb_frontend_name" {
  description = "[OPTIONAL] Name for internal load balancer frontend IP configuration"
  type        = string
  default     = "internal-lb-frontend"
}

variable "internal_lb_ip_allocation" {
  description = "[OPTIONAL] IP allocation method for internal load balancer"
  type        = string
  default     = "Dynamic"
}

variable "service_cidr" {
  description = "[OPTIONAL] CIDR range for Kubernetes services"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.service_cidr, 0))
    error_message = "Service CIDR must be a valid CIDR notation."
  }

  validation {
    condition     = tonumber(split("/", var.service_cidr)[1]) >= 12 && tonumber(split("/", var.service_cidr)[1]) <= 24
    error_message = "Service CIDR must be between /12 and /24 for optimal service allocation."
  }
}

variable "dns_service_ip" {
  description = "[OPTIONAL] IP address for DNS service within service CIDR"
  type        = string
  default     = "10.0.0.10"
}

variable "pod_cidr" {
  description = "[OPTIONAL] CIDR range for pods (only used with kubenet)"
  type        = string
  default     = "10.244.0.0/16"

  validation {
    condition     = can(cidrhost(var.pod_cidr, 0))
    error_message = "Pod CIDR must be a valid CIDR notation."
  }

  validation {
    condition     = tonumber(split("/", var.pod_cidr)[1]) >= 8 && tonumber(split("/", var.pod_cidr)[1]) <= 24
    error_message = "Pod CIDR must be between /8 and /24 for adequate pod IP allocation."
  }
}

# =============================================================================
# AUTOSCALER AND WORKLOAD VARIABLES
# =============================================================================

variable "enable_keda" {
  description = "[OPTIONAL] Enable KEDA for event-driven autoscaling"
  type        = bool
  default     = true
}

variable "enable_vertical_pod_autoscaler" {
  description = "[OPTIONAL] Enable Vertical Pod Autoscaler for right-sizing"
  type        = bool
  default     = true
}

variable "secret_rotation_interval" {
  description = "[REQUIRED] Interval for secret rotation in Key Vault CSI driver (GSO Secrets Management Policy)"
  type        = string
  default     = "2m"

  # GSO Secrets Management Policy: Secrets must be rotated in accordance with Encryption Standard
  validation {
    condition     = can(regex("^[0-9]+[smh]$", var.secret_rotation_interval))
    error_message = "GSO Secrets Management Policy: Secret rotation interval must be specified (format: 30s, 2m, 1h)."
  }

  validation {
    condition     = var.secret_rotation_interval != "0" && var.secret_rotation_interval != ""
    error_message = "GSO Secrets Management Policy: Secret rotation cannot be disabled (must have valid interval)."
  }
}

variable "enable_secret_rotation" {
  description = "[REQUIRED] Enable automatic secret rotation (GSO Secrets Management Policy)"
  type        = bool
  default     = true

  # GSO Secrets Management Policy: Automatic secret rotation is mandatory
  validation {
    condition     = var.enable_secret_rotation == true
    error_message = "GSO Secrets Management Policy: Automatic secret rotation is mandatory for compliance with Encryption Standard."
  }
}

variable "auto_scaler_profile" {
  description = "[OPTIONAL] Custom cluster autoscaler profile settings (only used if enable_auto_scaler_profile = true)"
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

# Diagnostics Configuration
variable "enable_diagnostics" {
  description = "[REQUIRED] Enable comprehensive logging and monitoring (GSO Logging Policy)"
  type        = bool
  default     = true

  # GSO Logging Policy: Logging must be implemented in accordance to the Security Log Management Standard
  validation {
    condition     = var.enable_diagnostics == true
    error_message = "GSO Logging Policy: Logging must be implemented in accordance to the Security Log Management Standard (control plane logs, host OS logs, worker node logs required)."
  }
}

variable "diagnostic_setting_name" {
  description = "Name of the diagnostic setting"
  type        = string
  default     = ""
}



variable "diagnostic_log_categories" {
  description = "List of diagnostic log categories"
  type        = list(string)
  default = [
    "kube-audit",
    "cluster-autoscaler",
    "kube-controller-manager",
    "kube-scheduler"
  ]
}

variable "diagnostic_metric_categories" {
  description = "List of diagnostic metric categories"
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "log_retention_days" {
  description = "Log retention period for audit trails and compliance requirements (GSO Policy LO_AKS_100)"
  type        = number
  default     = 100

  # GSO Policy LO_AKS_100: Ensure that Azure Kubernetes Service clusters have resource logs enabled with a retention period of at least 100 days
  validation {
    condition     = var.log_retention_days >= 100
    error_message = "GSO Policy LO_AKS_100: Azure Kubernetes Service clusters must have resource logs enabled with a retention period of at least 100 days."
  }
}



variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}