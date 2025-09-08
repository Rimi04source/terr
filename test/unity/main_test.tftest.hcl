# =============================================================================
# AKS MODULE UNIT TESTS
# =============================================================================
# These unit tests validate the core GSO security policy enforcement in the
# AKS Terraform module without deploying actual Azure resources.

# Pattern: Test private_cluster_enabled = true creates private AKS cluster
run "test_private_cluster_enabled_pass" {
  module {
    source = "../../"
  }
  command = plan

  variables {
    aks_cluster_name = "test-aks"
    resource_group_name = "test-rg"
    location = "East US"
    subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    vnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    use_existing_disk_encryption_set = true
    existing_disk_encryption_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Compute/diskEncryptionSets/test-des"
    aad_admin_group_object_ids = ["12345678-1234-1234-1234-123456789012"]
    api_server_authorized_ip_ranges = ["10.0.0.0/8"]
    private_cluster_enabled = true
    log_storage_type = "log_analytics"
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
    enable_backup = false
    enable_private_endpoints = true
    create_private_endpoints = true
    dependency_resource_ids = {
      acr_registry_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.ContainerRegistry/registries/test-acr"
      key_vault_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
      log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
      storage_account_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/testsa"
    }
    private_endpoints_subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/pe-subnet"
    enable_nat_gateway = true
    create_nat_gateway = true
    enable_availability_zones = true
    cluster_availability_zones = ["1", "2"]
    node_pools = {
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
        tags                = {}
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

  assert {
    condition     = azurerm_kubernetes_cluster.aks.private_cluster_enabled == true
    error_message = "Private cluster not enabled. Reason: private_cluster_enabled = false (must be true for GSO compliance)."
  }
}

# Anti-pattern: Test private_cluster_enabled = false (should fail validation)
run "test_private_cluster_disabled_fail" {
  module {
    source = "../../"
  }
  command = plan

  variables {
    aks_cluster_name = "test-aks"
    resource_group_name = "test-rg"
    location = "East US"
    subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    vnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    use_existing_disk_encryption_set = true
    existing_disk_encryption_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Compute/diskEncryptionSets/test-des"
    aad_admin_group_object_ids = ["12345678-1234-1234-1234-123456789012"]
    api_server_authorized_ip_ranges = ["10.0.0.0/8"]
    private_cluster_enabled = false
    log_storage_type = "log_analytics"
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
    enable_backup = false
    enable_private_endpoints = false
    enable_nat_gateway = false
    enable_availability_zones = true
    cluster_availability_zones = ["1", "2"]
    node_pools = {
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
        tags                = {}
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

  expect_failures = [terraform_data.validate_aks_configuration]
}

# Pattern: Test local_account_disabled = true disables local accounts
run "test_local_accounts_disabled_pass" {
  module {
    source = "../../"
  }
  command = plan

  variables {
    aks_cluster_name = "test-aks"
    resource_group_name = "test-rg"
    location = "East US"
    subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    vnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    use_existing_disk_encryption_set = true
    existing_disk_encryption_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Compute/diskEncryptionSets/test-des"
    aad_admin_group_object_ids = ["12345678-1234-1234-1234-123456789012"]
    api_server_authorized_ip_ranges = ["10.0.0.0/8"]
    local_account_disabled = true
    log_storage_type = "log_analytics"
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
    enable_backup = false
    enable_private_endpoints = false
    enable_nat_gateway = false
    enable_availability_zones = true
    cluster_availability_zones = ["1", "2"]
    node_pools = {
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
        tags                = {}
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

  assert {
    condition     = azurerm_kubernetes_cluster.aks.local_account_disabled == true
    error_message = "Local accounts not disabled. Reason: local_account_disabled = false (must be true for GSO compliance)."
  }
}

# Anti-pattern: Test local_account_disabled = false (should fail validation)
run "test_local_accounts_enabled_fail" {
  module {
    source = "../../"
  }
  command = plan

  variables {
    aks_cluster_name = "test-aks"
    resource_group_name = "test-rg"
    location = "East US"
    subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    vnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    use_existing_disk_encryption_set = true
    existing_disk_encryption_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Compute/diskEncryptionSets/test-des"
    aad_admin_group_object_ids = ["12345678-1234-1234-1234-123456789012"]
    api_server_authorized_ip_ranges = ["10.0.0.0/8"]
    local_account_disabled = false
    log_storage_type = "log_analytics"
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
    enable_backup = false
  }

  expect_failures = [var.local_account_disabled]
}

# Pattern: Test identity_type = "SystemAssigned" creates managed identity
run "test_system_assigned_identity_pass" {
  module {
    source = "../../"
  }
  command = plan

  variables {
    aks_cluster_name = "test-aks"
    resource_group_name = "test-rg"
    location = "East US"
    subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    vnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    use_existing_disk_encryption_set = true
    existing_disk_encryption_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Compute/diskEncryptionSets/test-des"
    aad_admin_group_object_ids = ["12345678-1234-1234-1234-123456789012"]
    api_server_authorized_ip_ranges = ["10.0.0.0/8"]
    identity_type = "SystemAssigned"
    log_storage_type = "log_analytics"
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
    enable_backup = false
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks.identity[0].type == "SystemAssigned"
    error_message = "Managed identity not configured. Reason: identity_type != SystemAssigned (must use managed identities for GSO compliance)."
  }
}

# Pattern: Test identity_type = "UserAssigned" with new identity creation
run "test_user_assigned_identity_new_pass" {
  module {
    source = "../../"
  }
  command = plan

  variables {
    aks_cluster_name = "test-aks"
    resource_group_name = "test-rg"
    location = "East US"
    subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    vnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    use_existing_disk_encryption_set = true
    existing_disk_encryption_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Compute/diskEncryptionSets/test-des"
    aad_admin_group_object_ids = ["12345678-1234-1234-1234-123456789012"]
    api_server_authorized_ip_ranges = ["10.0.0.0/8"]
    identity_type = "UserAssigned"
    user_assigned_identity_id = ""
    user_assigned_identity_name = "test-identity"
    log_storage_type = "log_analytics"
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
    enable_backup = false
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks.identity[0].type == "UserAssigned"
    error_message = "UserAssigned identity not configured correctly."
  }

  assert {
    condition     = length(azurerm_user_assigned_identity.aks) == 1
    error_message = "New UserAssigned identity not created when user_assigned_identity_id is empty."
  }
}

# Pattern: Test node_pools with managed disks
run "test_managed_disks_pass" {
  module {
    source = "../../"
  }
  command = plan

  variables {
    aks_cluster_name = "test-aks"
    resource_group_name = "test-rg"
    location = "East US"
    subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    vnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    use_existing_disk_encryption_set = true
    existing_disk_encryption_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Compute/diskEncryptionSets/test-des"
    aad_admin_group_object_ids = ["12345678-1234-1234-1234-123456789012"]
    api_server_authorized_ip_ranges = ["10.0.0.0/8"]
    log_storage_type = "log_analytics"
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
    enable_backup = false
    node_pools = {
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
        tags                = {}
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

  assert {
    condition     = azurerm_kubernetes_cluster.aks.default_node_pool[0].os_disk_type == "Managed"
    error_message = "Managed disks not configured. Reason: os_disk_type != Managed (must use managed disks for GSO compliance)."
  }
}

# Anti-pattern: Test node_pools with unmanaged disks (should fail validation)
run "test_unmanaged_disks_fail" {
  module {
    source = "../../"
  }
  command = plan

  variables {
    aks_cluster_name = "test-aks"
    resource_group_name = "test-rg"
    location = "East US"
    subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    vnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    use_existing_disk_encryption_set = true
    existing_disk_encryption_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Compute/diskEncryptionSets/test-des"
    aad_admin_group_object_ids = ["12345678-1234-1234-1234-123456789012"]
    api_server_authorized_ip_ranges = ["10.0.0.0/8"]
    log_storage_type = "log_analytics"
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
    enable_backup = false
    node_pools = {
      system = {
        name                = "systempool"
        mode                = "System"
        vm_size             = "Standard_D4s_v3"
        node_count          = 2
        enable_auto_scaling = false
        min_count           = 2
        max_count           = 3
        os_disk_size_gb     = 128
        os_disk_type        = "Ephemeral"
        availability_zones  = ["1"]
        enable_spot         = false
        enable_fips         = false
        os_sku              = "Ubuntu"
        os_type             = "Linux"
        node_labels         = {}
        tags                = {}
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

  expect_failures = [terraform_data.validate_node_pool_configuration]
}

# Anti-pattern: Test identity_type = "ServicePrincipal" (should fail validation)
run "test_service_principal_identity_fail" {
  module {
    source = "../../"
  }
  command = plan

  variables {
    aks_cluster_name = "test-aks"
    resource_group_name = "test-rg"
    location = "East US"
    subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    vnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    use_existing_disk_encryption_set = true
    existing_disk_encryption_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Compute/diskEncryptionSets/test-des"
    aad_admin_group_object_ids = ["12345678-1234-1234-1234-123456789012"]
    api_server_authorized_ip_ranges = ["10.0.0.0/8"]
    identity_type = "ServicePrincipal"
    log_storage_type = "log_analytics"
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
    enable_backup = false
  }

  expect_failures = [var.identity_type]
}

# Pattern: Test non-empty aad_admin_group_object_ids
run "test_aad_admin_groups_pass" {
  module {
    source = "../../"
  }
  command = plan

  variables {
    aks_cluster_name = "test-aks"
    resource_group_name = "test-rg"
    location = "East US"
    subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    vnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    use_existing_disk_encryption_set = true
    existing_disk_encryption_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Compute/diskEncryptionSets/test-des"
    aad_admin_group_object_ids = ["12345678-1234-1234-1234-123456789012", "87654321-4321-4321-4321-210987654321"]
    api_server_authorized_ip_ranges = ["10.0.0.0/8"]
    log_storage_type = "log_analytics"
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
    enable_backup = false
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.aks.azure_active_directory_role_based_access_control[0].admin_group_object_ids) > 0
    error_message = "AAD admin groups not configured. Reason: aad_admin_group_object_ids is empty (must have admin groups for GSO compliance)."
  }
}

# Anti-pattern: Test empty aad_admin_group_object_ids (should fail validation)
run "test_aad_admin_groups_empty_fail" {
  module {
    source = "../../"
  }
  command = plan

  variables {
    aks_cluster_name = "test-aks"
    resource_group_name = "test-rg"
    location = "East US"
    subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    vnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    use_existing_disk_encryption_set = true
    existing_disk_encryption_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Compute/diskEncryptionSets/test-des"
    aad_admin_group_object_ids = []
    api_server_authorized_ip_ranges = ["10.0.0.0/8"]
    log_storage_type = "log_analytics"
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
    enable_backup = false
  }

  expect_failures = [var.aad_admin_group_object_ids]
}
