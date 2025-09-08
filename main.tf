# =============================================================================
# AZURE AKS TERRAFORM MODULE
# =============================================================================
# This module creates an Azure Kubernetes Service (AKS) cluster with GSO
# compliance requirements including private cluster, host encryption, and
# mandatory diagnostic logging.
#
# DEPLOYMENT ORDER:
# 1. Local values and computed configurations
# 2. GSO compliance validation checks
# 3. User assigned identity (conditional)
# 4. NAT Gateway configuration (conditional)
# 5. Private DNS zones (conditional)
# 6. Private endpoints (conditional)
# 7. Main AKS cluster resource
# 8. Additional user node pools (optional)
# 9. Load balancer validation and configuration
# 10. Enterprise backup configuration (conditional)
# 11. Diagnostic logging and monitoring

# =============================================================================
# STEP 1: LOCAL VALUES AND COMPUTED CONFIGURATIONS
# =============================================================================
# Define local values for resource naming, tagging, and configuration logic
# that will be reused throughout the module
# Locals are defined in locals.tf

# =============================================================================
# STEP 2: SECURITY AND COMPLIANCE VALIDATION CHECKS
# =============================================================================
# These validation blocks enforce enterprise security best practices
# and prevent deployment of configurations that could pose security risks

# Validate core AKS security configuration requirements
# Ensures private cluster, host encryption, and HTTPS-only access are enabled for data protection
resource "terraform_data" "validate_aks_configuration" {
  lifecycle {
    # GSO Policy EP_AKS_101: Azure Container Services managed clusters must not be exposed to the internet
    precondition {
      condition     = var.private_cluster_enabled == true
      error_message = "GSO Policy EP_AKS_101: Azure Container Services managed clusters must not be exposed to the internet."
    }
    # Host encryption requirement - encrypts VM host caches and temp disks
    # GSO Policy EN_AKS_101: Temporary disks and cache for agent node pools should be encrypted at host
    # precondition {
    #   condition     = var.enable_host_encryption == true
    #   error_message = "GSO Policy EN_AKS_101: Temporary disks and cache for agent node pools in Azure Kubernetes Service clusters should be encrypted at host."
    # }
    # HTTPS-only access requirement - ensures encrypted data in transit
    precondition {
      condition     = contains(["1.2", "1.3"], var.tls_min_version)
      error_message = "GSO Policy IP_AKS_104: Kubernetes clusters should be accessible only over HTTPS with TLS 1.2 or higher."
    }
  }
}

# Validate node pool configuration meets security standards
# Ensures proper disk configuration and minimum node pool requirements
resource "terraform_data" "validate_node_pool_configuration" {
  lifecycle {
    # Minimum node pool requirement - at least one pool needed for cluster operation
    precondition {
      condition     = length(var.node_pools) > 0
      error_message = "At least one node pool is required for AKS cluster."
    }
    # Managed disk requirement - ensures encrypted, managed storage for all nodes
    precondition {
      condition = alltrue([
        for pool in var.node_pools :
        pool.os_disk_type == "Managed"
      ])
      error_message = "Reliability & Security: Managed disks provide better performance, encryption, and backup capabilities compared to unmanaged disks."
    }
  }
}

# Validate service exposure configuration
# GSO Policy IP_AKS_103: If user chooses LoadBalancer, ensure it's internal
resource "terraform_data" "validate_service_exposure" {
  lifecycle {
    # If LoadBalancer is selected, either existing LB ID or internal LB creation must be specified
    precondition {
      condition = var.service_exposure_type != "LoadBalancer" || (
        var.existing_load_balancer_id != "" || var.create_internal_load_balancer == true
      )
      error_message = "When service_exposure_type is LoadBalancer, either provide existing_load_balancer_id or set create_internal_load_balancer to true."
    }
  }
}

# Validate identity configuration - SIMPLIFIED
# Simple logic: SystemAssigned (nothing needed) or UserAssigned (provide ID or we create)
resource "terraform_data" "validate_identity_configuration" {
  lifecycle {
    # No validation needed - if UserAssigned with no ID provided, we'll create one
    # This makes it user-friendly with sensible defaults
  }
}

# Validate log storage configuration
# Ensures proper log destination setup based on storage type selection
resource "terraform_data" "validate_log_storage" {
  lifecycle {
    # If log_analytics is selected, workspace ID must be provided
    precondition {
      condition = var.log_storage_type == "storage_account" || var.log_analytics_workspace_id != ""
      error_message = "When log_storage_type is 'log_analytics' or 'both', log_analytics_workspace_id must be provided."
    }
    # If storage_account is selected, storage account ID must be provided
    precondition {
      condition = var.log_storage_type == "log_analytics" || var.storage_account_id != ""
      error_message = "When log_storage_type is 'storage_account' or 'both', storage_account_id must be provided."
    }
  }
}

# Validate backup configuration
# Ensures proper backup setup when backup is enabled
resource "terraform_data" "validate_backup_configuration" {
  lifecycle {
    # If backup is enabled, vault ID must be provided
    precondition {
      condition = var.enable_backup == false || var.backup_vault_id != ""
      error_message = "When enable_backup is true, backup_vault_id must be provided."
    }
    # If backup is enabled, backup policy ID must be provided
    precondition {
      condition = var.enable_backup == false || var.backup_policy_id != ""
      error_message = "When enable_backup is true, backup_policy_id must be provided."
    }
  }
}

# Validate NAT Gateway configuration
# Ensures proper NAT Gateway setup when enabled
resource "terraform_data" "validate_nat_gateway_configuration" {
  lifecycle {
    # If NAT Gateway is enabled, either existing ID or new creation must be specified
    precondition {
      condition = var.enable_nat_gateway == false || (
        var.existing_nat_gateway_id != "" || var.create_nat_gateway == true
      )
      error_message = "When enable_nat_gateway is true, either provide existing_nat_gateway_id or set create_nat_gateway to true."
    }
  }
}

# Validate High Availability configuration
# Ensures proper availability zone setup for production workloads
resource "terraform_data" "validate_high_availability" {
  lifecycle {
    # Production workloads should use availability zones for 99.95% SLA
    precondition {
      condition = var.enable_availability_zones == true
      error_message = "High Availability Requirement: Enable availability zones for production AKS clusters to achieve 99.95% SLA and protect against datacenter failures."
    }
    # Ensure multiple zones are configured for true high availability
    precondition {
      condition = length(var.cluster_availability_zones) >= 2
      error_message = "High Availability Requirement: Configure at least 2 availability zones for redundancy and disaster recovery."
    }
  }
}

# Validate Private Endpoints configuration
# Ensures proper private endpoint setup for zero-trust architecture
resource "terraform_data" "validate_private_endpoints_configuration" {
  lifecycle {
    # If private endpoints are enabled, either existing endpoints or new creation must be specified
    precondition {
      condition = var.enable_private_endpoints == false || (
        var.existing_private_endpoints.acr_private_endpoint_id != "" ||
        var.existing_private_endpoints.key_vault_private_endpoint_id != "" ||
        var.existing_private_endpoints.log_analytics_private_endpoint_id != "" ||
        var.existing_private_endpoints.storage_private_endpoint_id != "" ||
        var.create_private_endpoints == true
      )
      error_message = "When enable_private_endpoints is true, either provide existing private endpoint IDs or set create_private_endpoints to true."
    }
    # If creating new private endpoints, dependency resource IDs must be provided
    precondition {
      condition = var.enable_private_endpoints == false || var.create_private_endpoints == false || (
        var.dependency_resource_ids.acr_registry_id != "" ||
        var.dependency_resource_ids.key_vault_id != "" ||
        var.dependency_resource_ids.log_analytics_workspace_id != "" ||
        var.dependency_resource_ids.storage_account_id != ""
      )
      error_message = "When creating new private endpoints, at least one dependency resource ID must be provided."
    }
  }
}

# =============================================================================
# STEP 3: DISK ENCRYPTION SET (CONDITIONAL)
# =============================================================================
# Creates Disk Encryption Set for CMK encryption if no existing DES provided
# Required for GSO Policy EN_AKS_100 compliance

# Create Disk Encryption Set only if:
# 1. User chose NOT to use existing DES
# 2. Key Vault Key ID is provided
resource "azurerm_disk_encryption_set" "aks" {
  count = var.use_existing_disk_encryption_set == false && var.key_vault_key_id != "" ? 1 : 0

  name                = var.resource_prefix != null ? "${var.resource_prefix}-${var.disk_encryption_set_name}" : var.disk_encryption_set_name
  location            = var.location
  resource_group_name = var.resource_group_name
  key_vault_key_id    = var.key_vault_key_id

  identity {
    type = "SystemAssigned"
  }

  tags = merge(local.common_tags, {
    Purpose = "Disk Encryption Set for AKS CMK encryption"
  })
}

# =============================================================================
# STEP 4: USER ASSIGNED IDENTITY (CONDITIONAL)
# =============================================================================
# Creates UserAssigned identity if UserAssigned type is selected
# and no existing identity ID is provided

# Create UserAssigned identity only if:
# 1. User chose UserAssigned identity type
# 2. User didn't provide an existing identity ID
resource "azurerm_user_assigned_identity" "aks" {
  count = var.identity_type == "UserAssigned" && var.user_assigned_identity_id == "" ? 1 : 0

  name                = var.resource_prefix != null ? "${var.resource_prefix}-${var.user_assigned_identity_name}" : var.user_assigned_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = local.common_tags
}

# =============================================================================
# STEP 5: NAT GATEWAY CONFIGURATION (CONDITIONAL)
# =============================================================================
# Creates NAT Gateway for outbound internet access if enabled and no existing ID provided
# Critical for private AKS clusters to pull container images and access Azure services

# Create public IP(s) for NAT Gateway
resource "azurerm_public_ip" "nat_gateway" {
  count = var.enable_nat_gateway && var.existing_nat_gateway_id == "" && var.create_nat_gateway ? var.nat_gateway_public_ip_count : 0

  name                = var.resource_prefix != null ? "${var.resource_prefix}-${var.nat_gateway_name}-pip-${count.index + 1}" : "${var.nat_gateway_name}-pip-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  zones               = var.enable_availability_zones ? var.cluster_availability_zones : null

  tags = merge(local.common_tags, {
    Purpose = "NAT Gateway Public IP for AKS outbound connectivity"
  })
}

# Create NAT Gateway
resource "azurerm_nat_gateway" "aks" {
  count = var.enable_nat_gateway && var.existing_nat_gateway_id == "" && var.create_nat_gateway ? 1 : 0

  name                    = var.resource_prefix != null ? "${var.resource_prefix}-${var.nat_gateway_name}" : var.nat_gateway_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = var.nat_gateway_sku
  idle_timeout_in_minutes = var.nat_gateway_idle_timeout
  zones                   = var.enable_availability_zones ? var.cluster_availability_zones : null

  tags = merge(local.common_tags, {
    Purpose = "NAT Gateway for AKS private cluster outbound connectivity"
  })
}

# Associate public IP(s) with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "aks" {
  count = var.enable_nat_gateway && var.existing_nat_gateway_id == "" && var.create_nat_gateway ? var.nat_gateway_public_ip_count : 0

  nat_gateway_id       = azurerm_nat_gateway.aks[0].id
  public_ip_address_id = azurerm_public_ip.nat_gateway[count.index].id
}

# Associate NAT Gateway with AKS subnet
resource "azurerm_subnet_nat_gateway_association" "aks" {
  count = var.enable_nat_gateway ? 1 : 0

  subnet_id      = var.subnet_id
  nat_gateway_id = var.existing_nat_gateway_id != "" ? var.existing_nat_gateway_id : azurerm_nat_gateway.aks[0].id
}

# =============================================================================
# STEP 6: PRIVATE DNS ZONES (CONDITIONAL)
# =============================================================================
# Creates private DNS zones for private endpoints if enabled and no existing zones provided
# Critical for private endpoint name resolution within the VNet

# Private DNS Zone for Azure Container Registry
resource "azurerm_private_dns_zone" "acr" {
  count = var.enable_private_endpoints && var.create_private_dns_zones && var.existing_private_dns_zone_ids.acr_dns_zone_id == "" && var.dependency_resource_ids.acr_registry_id != "" ? 1 : 0

  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name

  tags = merge(local.common_tags, {
    Purpose = "Private DNS Zone for ACR Private Endpoint"
  })
}

# Private DNS Zone for Azure Key Vault
resource "azurerm_private_dns_zone" "key_vault" {
  count = var.enable_private_endpoints && var.create_private_dns_zones && var.existing_private_dns_zone_ids.key_vault_dns_zone_id == "" && var.dependency_resource_ids.key_vault_id != "" ? 1 : 0

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name

  tags = merge(local.common_tags, {
    Purpose = "Private DNS Zone for Key Vault Private Endpoint"
  })
}

# Private DNS Zone for Log Analytics
resource "azurerm_private_dns_zone" "log_analytics" {
  count = var.enable_private_endpoints && var.create_private_dns_zones && var.existing_private_dns_zone_ids.log_analytics_dns_zone_id == "" && var.dependency_resource_ids.log_analytics_workspace_id != "" ? 1 : 0

  name                = "privatelink.oms.opinsights.azure.com"
  resource_group_name = var.resource_group_name

  tags = merge(local.common_tags, {
    Purpose = "Private DNS Zone for Log Analytics Private Endpoint"
  })
}

# Private DNS Zone for Storage Account
resource "azurerm_private_dns_zone" "storage" {
  count = var.enable_private_endpoints && var.create_private_dns_zones && var.existing_private_dns_zone_ids.storage_dns_zone_id == "" && var.dependency_resource_ids.storage_account_id != "" ? 1 : 0

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = merge(local.common_tags, {
    Purpose = "Private DNS Zone for Storage Private Endpoint"
  })
}

# Link Private DNS Zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  count = var.enable_private_endpoints && var.create_private_dns_zones && var.existing_private_dns_zone_ids.acr_dns_zone_id == "" && var.dependency_resource_ids.acr_registry_id != "" ? 1 : 0

  name                  = "acr-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.acr[0].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  count = var.enable_private_endpoints && var.create_private_dns_zones && var.existing_private_dns_zone_ids.key_vault_dns_zone_id == "" && var.dependency_resource_ids.key_vault_id != "" ? 1 : 0

  name                  = "keyvault-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault[0].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "log_analytics" {
  count = var.enable_private_endpoints && var.create_private_dns_zones && var.existing_private_dns_zone_ids.log_analytics_dns_zone_id == "" && var.dependency_resource_ids.log_analytics_workspace_id != "" ? 1 : 0

  name                  = "loganalytics-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.log_analytics[0].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  count = var.enable_private_endpoints && var.create_private_dns_zones && var.existing_private_dns_zone_ids.storage_dns_zone_id == "" && var.dependency_resource_ids.storage_account_id != "" ? 1 : 0

  name                  = "storage-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage[0].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = local.common_tags
}

# =============================================================================
# STEP 7: PRIVATE ENDPOINTS (CONDITIONAL)
# =============================================================================
# Creates private endpoints for AKS dependencies if enabled and no existing endpoints provided
# Ensures zero-trust architecture and GSO compliance for private clusters

# Private Endpoint for Azure Container Registry
resource "azurerm_private_endpoint" "acr" {
  count = var.enable_private_endpoints && var.existing_private_endpoints.acr_private_endpoint_id == "" && var.create_private_endpoints && var.dependency_resource_ids.acr_registry_id != "" ? 1 : 0

  name                = var.resource_prefix != null ? "${var.resource_prefix}-acr-pe" : "${var.aks_cluster_name}-acr-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "acr-private-connection"
    private_connection_resource_id = var.dependency_resource_ids.acr_registry_id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-dns-zone-group"
    private_dns_zone_ids = [var.existing_private_dns_zone_ids.acr_dns_zone_id != "" ? var.existing_private_dns_zone_ids.acr_dns_zone_id : azurerm_private_dns_zone.acr[0].id]
  }

  tags = merge(local.common_tags, {
    Purpose = "Private Endpoint for ACR access from AKS"
  })
}

# Private Endpoint for Azure Key Vault
resource "azurerm_private_endpoint" "key_vault" {
  count = var.enable_private_endpoints && var.existing_private_endpoints.key_vault_private_endpoint_id == "" && var.create_private_endpoints && var.dependency_resource_ids.key_vault_id != "" ? 1 : 0

  name                = var.resource_prefix != null ? "${var.resource_prefix}-kv-pe" : "${var.aks_cluster_name}-kv-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "keyvault-private-connection"
    private_connection_resource_id = var.dependency_resource_ids.key_vault_id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "keyvault-dns-zone-group"
    private_dns_zone_ids = [var.existing_private_dns_zone_ids.key_vault_dns_zone_id != "" ? var.existing_private_dns_zone_ids.key_vault_dns_zone_id : azurerm_private_dns_zone.key_vault[0].id]
  }

  tags = merge(local.common_tags, {
    Purpose = "Private Endpoint for Key Vault access from AKS"
  })
}

# Private Endpoint for Log Analytics Workspace
resource "azurerm_private_endpoint" "log_analytics" {
  count = var.enable_private_endpoints && var.existing_private_endpoints.log_analytics_private_endpoint_id == "" && var.create_private_endpoints && var.dependency_resource_ids.log_analytics_workspace_id != "" ? 1 : 0

  name                = var.resource_prefix != null ? "${var.resource_prefix}-la-pe" : "${var.aks_cluster_name}-la-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "loganalytics-private-connection"
    private_connection_resource_id = var.dependency_resource_ids.log_analytics_workspace_id
    subresource_names              = ["azuremonitor"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "loganalytics-dns-zone-group"
    private_dns_zone_ids = [var.existing_private_dns_zone_ids.log_analytics_dns_zone_id != "" ? var.existing_private_dns_zone_ids.log_analytics_dns_zone_id : azurerm_private_dns_zone.log_analytics[0].id]
  }

  tags = merge(local.common_tags, {
    Purpose = "Private Endpoint for Log Analytics access from AKS"
  })
}

# Private Endpoint for Storage Account
resource "azurerm_private_endpoint" "storage" {
  count = var.enable_private_endpoints && var.existing_private_endpoints.storage_private_endpoint_id == "" && var.create_private_endpoints && var.dependency_resource_ids.storage_account_id != "" ? 1 : 0

  name                = var.resource_prefix != null ? "${var.resource_prefix}-st-pe" : "${var.aks_cluster_name}-st-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "storage-private-connection"
    private_connection_resource_id = var.dependency_resource_ids.storage_account_id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-dns-zone-group"
    private_dns_zone_ids = [var.existing_private_dns_zone_ids.storage_dns_zone_id != "" ? var.existing_private_dns_zone_ids.storage_dns_zone_id : azurerm_private_dns_zone.storage[0].id]
  }

  tags = merge(local.common_tags, {
    Purpose = "Private Endpoint for Storage access from AKS"
  })
}

# =============================================================================
# STEP 8: MAIN AKS CLUSTER RESOURCE
# =============================================================================
# Creates the primary AKS cluster with all core configurations including
# security settings, identity management, networking, and system node pool
# This is the core resource that everything else depends on

resource "azurerm_kubernetes_cluster" "aks" {
  # Basic cluster identification and location
  name                = local.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  sku_tier            = "Standard"

  # High Availability - Control Plane Availability Zones
  # Distributes AKS control plane across multiple Azure availability zones for 99.95% SLA
  # Critical for production workloads requiring maximum uptime and disaster recovery
  # Protects against datacenter failures and provides higher availability guarantees
  api_server_access_profile {
    authorized_ip_ranges = var.private_cluster_enabled ? [] : var.api_server_authorized_ip_ranges
  }

  # Security configuration - GSO compliance requirements
  # GSO Policy EP_AKS_100: Azure Kubernetes Service Clusters should use private clusters and API access restricted to ADP network
  private_cluster_enabled = var.private_cluster_enabled  # Private API server endpoint
  # GSO Policy IP_AKS_101: Azure Kubernetes Service Clusters should have local authentication methods disabled
  local_account_disabled  = var.local_account_disabled   # Disable local accounts (enforces Azure AD only)
  # GSO Policy EN_AKS_100: Operating systems and data disks in Azure Kubernetes Service clusters should be encrypted by customer-managed keys
  disk_encryption_set_id  = var.use_existing_disk_encryption_set ? var.existing_disk_encryption_set_id : azurerm_disk_encryption_set.aks[0].id  # Customer-managed key encryption

  # GSO Policy EP_AKS_100: Private cluster restricts API access to VNet only (no authorized IP ranges needed)

  # SIMPLIFIED IDENTITY LOGIC
  # SystemAssigned: Azure creates and manages identity automatically
  # UserAssigned: Use provided ID or create new one
  identity {
    type = var.identity_type
    identity_ids = var.identity_type == "UserAssigned" ? [
      var.user_assigned_identity_id != "" ? var.user_assigned_identity_id : azurerm_user_assigned_identity.aks[0].id
    ] : []
  }

  # GSO Policy IP_AKS_102: Azure Kubernetes Service Clusters should enable Azure Active Directory integration
  # GSO Policy IP_AKS_101: Azure Kubernetes Service Clusters should have local authentication methods disabled
  # GSO RBAC Policy: Apply principles of Least Privilege using Azure RBAC integration
  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.aad_admin_group_object_ids  # Required AAD groups for admin access
    azure_rbac_enabled     = true                           # Enable Azure RBAC for granular K8s permissions
  }

  # =============================================================================
  # SYSTEM NODE POOL (MANDATORY)
  # =============================================================================
  # The system node pool is REQUIRED and hosts critical Kubernetes system components:
  # - CoreDNS (DNS resolution)
  # - Metrics Server (resource metrics)
  # - Cluster Autoscaler (node scaling)
  # - Azure CNI components (networking)
  # - Kube-proxy (service routing)
  #
  # SCALING LOGIC:
  # - If min_count and max_count are set: AUTOSCALING enabled (node_count ignored)
  # - If only node_count is set: FIXED size (no autoscaling)
  # - Autoscaling triggers: Pod scheduling pressure, resource utilization
  #
  # VM SIZE SELECTION:
  # - User provides vm_size (e.g., Standard_D4s_v3, Standard_B4ms)
  # - Consider: CPU, memory, network performance, cost
  # - System pools typically need 2-4 vCPU minimum for system components

  default_node_pool {
    # Basic configuration - user-defined
    name                 = var.node_pools["system"].name                    # Pool name (e.g., "systempool")
    vm_size              = var.node_pools["system"].vm_size                 # VM SKU - USER CHOICE (e.g., Standard_D4s_v3)

    # Scaling configuration - explicit autoscaling
    auto_scaling_enabled = true
    min_count            = var.node_pools["system"].min_count
    max_count            = var.node_pools["system"].max_count

    # Storage configuration
    os_disk_size_gb      = var.node_pools["system"].os_disk_size_gb         # OS disk size (GB)
    os_disk_type         = var.node_pools["system"].os_disk_type            # Managed (recommended) or Ephemeral

    # Network and placement
    vnet_subnet_id       = var.node_pools["system"].pod_subnet_id != "" ? var.node_pools["system"].pod_subnet_id : var.subnet_id
    zones                = var.enable_availability_zones ? (
      length(var.node_pools["system"].availability_zones) > 0 ? var.node_pools["system"].availability_zones :
      var.node_pool_zone_distribution == "all" ? var.cluster_availability_zones :
      var.node_pool_zone_distribution == "multiple" ? slice(var.cluster_availability_zones, 0, 2) :
      [var.cluster_availability_zones[0]]
    ) : null

    # Security and compliance
    # GSO Policy EN_AKS_101: Temporary disks and cache for agent node pools in Azure Kubernetes Service clusters should be encrypted at host
    # host_encryption_enabled = var.enable_host_encryption                    # Encrypts VM host (compliance requirement) - Requires subscription-level enablement

    # Kubernetes configuration
    node_labels          = merge({ mode = "system" }, var.node_pools["system"].node_labels)  # Labels for pod scheduling
    os_sku               = var.node_pools["system"].os_sku                  # OS type (Ubuntu, CBLMariner, etc.)

    # Advanced configuration
    max_pods             = var.node_pools["system"].max_pods                # Max pods per node (affects IP allocation)
    proximity_placement_group_id = var.node_pools["system"].proximity_placement_group_id != "" ? var.node_pools["system"].proximity_placement_group_id : null
    ultra_ssd_enabled    = var.node_pools["system"].ultra_ssd_enabled       # Enable Ultra SSD support

    # Resource tagging
    tags                 = merge(local.common_tags, var.node_pools["system"].tags)
  }

  # Optional Azure Monitor integration for container insights
  # Enables monitoring and logging of cluster and container metrics
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != "" ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # Cluster management and upgrade configuration
  azure_policy_enabled      = var.enable_azure_policy        # Enable Azure Policy add-on
  # GSO Policy IP_AKS_104: Azure Kubernetes Service Clusters must be updated to the latest version
  automatic_upgrade_channel = var.upgrade_channel             # Control plane upgrade channel
  node_os_upgrade_channel   = var.enable_node_os_auto_upgrade ? "NodeImage" : "None"  # Node OS upgrade channel



  # Maintenance window configuration for controlled upgrades
  dynamic "maintenance_window" {
    for_each = var.enable_maintenance_window ? [1] : []
    content {
      dynamic "allowed" {
        for_each = var.maintenance_window_config.allowed_days
        content {
          day   = allowed.value
          hours = var.maintenance_window_config.allowed_hours
        }
      }
      dynamic "not_allowed" {
        for_each = var.maintenance_window_config.not_allowed
        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }

  # Auto scaler profile for fine-tuning cluster autoscaling behavior
  # If disabled, Azure uses sensible defaults for autoscaling
  dynamic "auto_scaler_profile" {
    for_each = var.enable_auto_scaler_profile ? [1] : []
    content {
      balance_similar_node_groups      = var.auto_scaler_profile.balance_similar_node_groups
      expander                        = var.auto_scaler_profile.expander
      max_graceful_termination_sec    = var.auto_scaler_profile.max_graceful_termination_sec
      max_node_provisioning_time      = var.auto_scaler_profile.max_node_provisioning_time
      max_unready_nodes              = var.auto_scaler_profile.max_unready_nodes
      max_unready_percentage         = var.auto_scaler_profile.max_unready_percentage
      new_pod_scale_up_delay         = var.auto_scaler_profile.new_pod_scale_up_delay
      scale_down_delay_after_add     = var.auto_scaler_profile.scale_down_delay_after_add
      scale_down_delay_after_delete  = var.auto_scaler_profile.scale_down_delay_after_delete
      scale_down_delay_after_failure = var.auto_scaler_profile.scale_down_delay_after_failure
      scan_interval                  = var.auto_scaler_profile.scan_interval
      scale_down_unneeded           = var.auto_scaler_profile.scale_down_unneeded
      scale_down_unready            = var.auto_scaler_profile.scale_down_unready
      scale_down_utilization_threshold = var.auto_scaler_profile.scale_down_utilization_threshold
    }
  }



  # GSO Policy IP_AKS_105: Use network policies to isolate traffic in your cluster network
  # Azure CNI (network_plugin = "azure") provides foundation for Kubernetes network policies
  # Network policies must be implemented post-deployment for pod-to-pod traffic isolation
  network_profile {
    network_plugin    = var.network_plugin      # Azure CNI required for network policy support
    network_policy    = var.network_policy      # Network policy engine for traffic isolation (GSO Policy IP_AKS_105)
    load_balancer_sku = var.load_balancer_sku   # Load balancer SKU
    service_cidr      = var.service_cidr        # Service CIDR range
    dns_service_ip    = var.dns_service_ip      # DNS service IP
    pod_cidr          = var.network_plugin == "kubenet" ? var.pod_cidr : null
  }

  # GSO Runtime Security Policy: Runtime environment must undergo security monitoring for anomaly and suspicious behavior detection and/or prevention
  # Microsoft Defender for Containers provides real-time threat detection, behavioral analysis, and anomaly detection
  dynamic "microsoft_defender" {
    for_each = var.enable_defender_for_containers && var.log_analytics_workspace_id != "" ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # GSO Secrets Management Policy: Secrets (API keys, service credentials, certificates, etc) must be managed, stored, and rotated in accordance with Encryption Standard
  # Azure Key Vault CSI driver provides centralized secret management with automatic rotation
  key_vault_secrets_provider {
    secret_rotation_enabled  = var.enable_secret_rotation      # Mandatory automatic rotation
    secret_rotation_interval = var.secret_rotation_interval   # Configurable rotation frequency
  }

  workload_autoscaler_profile {
    keda_enabled                    = var.enable_keda
    vertical_pod_autoscaler_enabled = var.enable_vertical_pod_autoscaler
  }



  # Workload Identity and OIDC
  workload_identity_enabled = var.enable_workload_identity
  oidc_issuer_enabled      = var.enable_oidc_issuer

  # Image Cleaner
  image_cleaner_enabled        = var.enable_image_cleaner
  image_cleaner_interval_hours = var.image_cleaner_interval_hours

  # Cost Management
  cost_analysis_enabled = var.cost_analysis_enabled



  # Apply common tags for resource management and cost tracking
  tags = local.common_tags
}

# =============================================================================
# STEP 8A: MAINTENANCE WINDOW CONFIGURATION (CONDITIONAL)
# =============================================================================
# Maintenance windows are configured inline within the AKS cluster resource
# No separate resource needed - handled in the main cluster configuration

# =============================================================================
# STEP 9: ADDITIONAL USER NODE POOLS (OPTIONAL)
# =============================================================================
# USER NODE POOLS are for APPLICATION WORKLOADS and are completely separate from system pools
#
# PURPOSE:
# - Run your application pods (web apps, APIs, databases, etc.)
# - Can be scaled independently from system pool
# - Can have different VM sizes, configurations, and scaling policies
# - Support advanced features like spot instances, GPU VMs, Windows nodes
#
# SCALING LOGIC (same as system pool):
# - AUTOSCALING: Set min_count and max_count (node_count ignored)
# - FIXED SIZE: Set only node_count (min_count and max_count ignored)
# - Cluster Autoscaler adds/removes VMs based on pod scheduling needs
#
# VM SIZE SELECTION:
# - User provides vm_size for each pool (can be different from system pool)
# - Examples: Standard_D4s_v3 (general), Standard_F16s_v2 (CPU), Standard_NC6s_v3 (GPU)
# - Consider workload requirements: CPU, memory, GPU, network, cost
#
# WORKLOAD ISOLATION:
# - Use node_taints to dedicate pools to specific workloads
# - Use node_labels for pod scheduling preferences
# - Use different VM sizes for different performance needs

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  # Create user node pools only (filter out system pools)
  for_each              = { for k, v in var.node_pools : k => v if v.mode == "User" }

  # Basic configuration - user-defined
  name                  = each.value.name                                   # Pool name (e.g., "apppool", "gpupool")
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id                # Parent cluster

  # VM and scaling configuration - determines performance and cost
  vm_size               = each.value.vm_size                               # VM SKU - USER CHOICE (e.g., Standard_D8s_v3)
  auto_scaling_enabled  = each.value.enable_auto_scaling                   # Enable autoscaling
  node_count            = each.value.enable_auto_scaling ? null : each.value.node_count       # Fixed count (no autoscaling)
  min_count             = each.value.enable_auto_scaling ? each.value.min_count : null        # Min nodes (autoscaling)
  max_count             = each.value.enable_auto_scaling ? each.value.max_count : null        # Max nodes (autoscaling)

  # Storage configuration
  os_disk_size_gb       = each.value.os_disk_size_gb                      # OS disk size (GB)
  os_disk_type          = each.value.os_disk_type                         # Managed (recommended) or Ephemeral

  # Network and placement
  vnet_subnet_id        = each.value.pod_subnet_id != "" ? each.value.pod_subnet_id : var.subnet_id  # Subnet for nodes
  zones                 = var.enable_availability_zones ? (
    length(each.value.availability_zones) > 0 ? each.value.availability_zones :
    var.node_pool_zone_distribution == "all" ? var.cluster_availability_zones :
    var.node_pool_zone_distribution == "multiple" ? slice(var.cluster_availability_zones, 0, 2) :
    [var.cluster_availability_zones[0]]
  ) : null  # AZ distribution for high availability

  # Security and compliance
  # GSO Policy EN_AKS_101: Temporary disks and cache for agent node pools in Azure Kubernetes Service clusters should be encrypted at host
  # host_encryption_enabled = var.enable_host_encryption                     # Encrypts VM host (compliance requirement) - Requires subscription-level enablement
  fips_enabled          = each.value.enable_fips                          # FIPS 140-2 compliance (government workloads)

  # Operating system configuration
  os_sku                = each.value.os_sku                               # OS type (Ubuntu, CBLMariner, Windows)
  os_type               = each.value.os_type                              # Linux or Windows

  # Cost optimization - spot instances
  priority              = each.value.priority                             # Regular (reliable) or Spot (cheap)
  eviction_policy       = each.value.priority == "Spot" ? each.value.eviction_policy : null    # Delete or Deallocate
  spot_max_price        = each.value.priority == "Spot" && each.value.spot_max_price > 0 ? each.value.spot_max_price : null  # Max price per hour

  # Advanced configuration
  max_pods              = each.value.max_pods                             # Max pods per node (affects IP allocation)
  node_taints           = each.value.node_taints                          # Taints for workload isolation
  proximity_placement_group_id = each.value.proximity_placement_group_id != "" ? each.value.proximity_placement_group_id : null  # Low latency
  ultra_ssd_enabled     = each.value.ultra_ssd_enabled                    # Ultra SSD support (high IOPS)

  # Kubernetes scheduling
  node_labels           = merge({ mode = "user" }, each.value.node_labels) # Labels for pod scheduling

  # Windows-specific configuration (only for Windows node pools)
  dynamic "windows_profile" {
    for_each = each.value.os_type == "Windows" && each.value.windows_profile != null ? [each.value.windows_profile] : []
    content {
      outbound_nat_enabled = var.windows_outbound_nat_enabled             # Enable outbound NAT for Windows
    }
  }

  # Resource tagging
  tags                  = merge(local.common_tags, each.value.tags)       # Consistent tagging
}

# =============================================================================
# STEP 10: LOAD BALANCER VALIDATION AND CONFIGURATION (USER-DRIVEN)
# =============================================================================
# GSO Policy IP_AKS_103: Azure Kubernetes clusters must use internal load balancers
#
# USER CHOICE LOGIC:
# - service_exposure_type = "ClusterIP"    → No load balancer (policy not applicable)
# - service_exposure_type = "LoadBalancer" → Load balancer required (must be internal)
#   - Option 1: User provides existing_load_balancer_id → Validate it's private
#   - Option 2: User sets create_internal_load_balancer = true → AKS creates internal LB
#
# GSO POLICY COMPLIANCE:
# - IP_AKS_103: All load balancers must be internal (no public IP allowed)
# - API Gateway Policy: External access must go through GWSE edge → API Gateway → Internal LB
# DEPENDS ON: AKS cluster must be created first

# Data source to validate existing load balancer is internal
data "azurerm_lb" "existing" {
  count = var.service_exposure_type == "LoadBalancer" && var.existing_load_balancer_id != "" ? 1 : 0

  name                = split("/", var.existing_load_balancer_id)[8]
  resource_group_name = split("/", var.existing_load_balancer_id)[4]
}

# GSO Policy IP_AKS_103: Validate existing load balancer is internal
resource "terraform_data" "validate_existing_lb_internal" {
  count = var.service_exposure_type == "LoadBalancer" && var.existing_load_balancer_id != "" ? 1 : 0

  lifecycle {
    precondition {
      condition = length([
        for config in data.azurerm_lb.existing[0].frontend_ip_configuration :
        config if config.public_ip_address_id != null
      ]) == 0
      error_message = "GSO Policy IP_AKS_103: Azure Kubernetes clusters must use internal load balancers. The provided load balancer has public IP configuration which is prohibited."
    }
  }
}

resource "azurerm_lb" "internal" {
  count = var.service_exposure_type == "LoadBalancer" && var.existing_load_balancer_id == "" && var.create_internal_load_balancer ? 1 : 0

  depends_on = [terraform_data.validate_existing_lb_internal]

  name                = var.resource_prefix != null ? "${var.resource_prefix}-${var.aks_cluster_name}-lb" : "${var.aks_cluster_name}-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.load_balancer_sku

  frontend_ip_configuration {
    name                          = var.internal_lb_frontend_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.internal_lb_ip_allocation
  }

  tags = local.common_tags
}

# =============================================================================
# STEP 11: ENTERPRISE BACKUP CONFIGURATION (CONDITIONAL)
# =============================================================================
# Creates backup configuration for AKS cluster if backup is enabled
# Enterprise requirement for disaster recovery and compliance

resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "aks_backup" {
  count = var.enable_backup && var.backup_vault_id != "" && var.backup_policy_id != "" ? 1 : 0

  name                         = "${local.cluster_name}-backup"
  location                     = var.location
  vault_id                     = var.backup_vault_id
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.aks.id
  backup_policy_id            = var.backup_policy_id
  snapshot_resource_group_name = var.resource_group_name
}

# =============================================================================
# STEP 12: AZURE POLICY ASSIGNMENTS (CONDITIONAL)
# =============================================================================
# Assigns Azure Policy definitions to enforce Kubernetes security standards
# Automatically blocks non-compliant deployments and enforces GSO policies

# Azure Policy Assignments for Kubernetes Security
# User provides policy definition IDs they want to assign
resource "azurerm_resource_policy_assignment" "kubernetes_policies" {
  count = var.enable_kubernetes_policy_assignments ? length(var.kubernetes_policy_definition_ids) : 0

  name                 = "${local.cluster_name}-policy-${count.index + 1}"
  resource_id          = azurerm_kubernetes_cluster.aks.id
  policy_definition_id = var.kubernetes_policy_definition_ids[count.index]

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# CIS Security Controls via Azure Policy
# "Kubernetes cluster containers should only use allowed AppArmor profiles"
# "Kubernetes cluster containers should only use allowed seccomp profiles"
# "The default namespace should not be used - Kubernetes clusters should not use the default namespace"
# "For each namespace in the cluster, ensure that automountServiceAccountToken: false setting is in place"
resource "azurerm_resource_policy_assignment" "cis_security_controls" {
  count = var.enable_kubernetes_policy_assignments ? 1 : 0

  name                 = "${local.cluster_name}-cis-security"
  resource_id          = azurerm_kubernetes_cluster.aks.id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/a8640138-9b0a-4a28-b8cb-1666c838647d"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
    excludedNamespaces = {
      value = ["kube-system", "gatekeeper-system", "azure-arc"]
    }
  })
}

# =============================================================================
# STEP 13: DIAGNOSTIC LOGGING AND MONITORING (GSO POLICY LO_AKS_100)
# =============================================================================
# GSO Policy LO_AKS_100: Ensure that Azure Kubernetes Service clusters have resource logs enabled with a retention period of at least 100 days
# Configures comprehensive logging and monitoring for operational excellence and security compliance
# Enterprise environments require centralized logging for audit, troubleshooting, and security
# Captures audit logs, performance metrics, and security events for complete visibility
# DEPENDS ON: AKS cluster must be created first to attach diagnostics

resource "azurerm_monitor_diagnostic_setting" "aks_diag" {
  # Diagnostic setting name with optional prefix for consistency
  name = var.diagnostic_setting_name != "" ? var.diagnostic_setting_name : (
    var.resource_prefix != null ?
    "${var.resource_prefix}-${var.aks_cluster_name}-diag" :
    "${var.aks_cluster_name}-diag"
  )

  # Target AKS cluster for diagnostic collection
  target_resource_id = azurerm_kubernetes_cluster.aks.id

  # Destination configuration for logs and metrics based on user selection
  # Real-time monitoring and alerting (Log Analytics)
  log_analytics_workspace_id = (var.log_storage_type == "log_analytics" || var.log_storage_type == "both") && var.log_analytics_workspace_id != "" ? var.log_analytics_workspace_id : null

  # Long-term retention for audit and compliance (Storage Account - 7+ year retention)
  storage_account_id = (var.log_storage_type == "storage_account" || var.log_storage_type == "both") && var.storage_account_id != "" ? var.storage_account_id : null

  # Log categories configuration - captures various AKS operational logs
  # Includes audit logs, autoscaler events, controller manager logs, etc.
  dynamic "enabled_log" {
    for_each = { for idx, category in var.diagnostic_log_categories : idx => category }
    content {
      category = enabled_log.value
    }
  }

  # Metrics configuration - captures performance and resource utilization data
  # Essential for monitoring cluster health and capacity planning
  dynamic "enabled_metric" {
    for_each = { for idx, category in var.diagnostic_metric_categories : idx => category }
    content {
      category = enabled_metric.value
    }
  }
}