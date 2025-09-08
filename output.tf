# AKS Cluster outputs
output "aks_cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_fqdn" {
  description = "AKS cluster FQDN"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_private_fqdn" {
  description = "AKS cluster private FQDN"
  value       = azurerm_kubernetes_cluster.aks.private_fqdn
}

# Kubeconfig outputs
output "kube_config_raw" {
  description = "Raw kubeconfig for AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kube_config" {
  description = "Structured kubeconfig for AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config
  sensitive   = true
}

# Identity outputs
output "cluster_identity" {
  description = "AKS cluster managed identity"
  value       = azurerm_kubernetes_cluster.aks.identity
}

output "kubelet_identity" {
  description = "AKS cluster kubelet identity"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity
}

output "user_assigned_identity_id" {
  description = "User assigned identity ID (if created)"
  value       = var.identity_type == "UserAssigned" && var.user_assigned_identity_id == "" ? azurerm_user_assigned_identity.aks[0].id : null
}

output "user_assigned_identity_principal_id" {
  description = "User assigned identity principal ID (if created)"
  value       = var.identity_type == "UserAssigned" && var.user_assigned_identity_id == "" ? azurerm_user_assigned_identity.aks[0].principal_id : null
}

output "user_assigned_identity_client_id" {
  description = "User assigned identity client ID (if created)"
  value       = var.identity_type == "UserAssigned" && var.user_assigned_identity_id == "" ? azurerm_user_assigned_identity.aks[0].client_id : null
}

# Node Pool outputs
output "node_resource_group" {
  description = "The auto-generated resource group which contains the resources for this managed Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "system_node_pool_name" {
  description = "System node pool name"
  value       = azurerm_kubernetes_cluster.aks.default_node_pool[0].name
}

output "user_node_pool_ids" {
  description = "User node pool IDs"
  value       = { for k, v in azurerm_kubernetes_cluster_node_pool.user : k => v.id }
}

# Network outputs
output "network_profile" {
  description = "AKS cluster network profile"
  value       = azurerm_kubernetes_cluster.aks.network_profile
}

# Diagnostic Settings Output
output "diagnostics_enabled" {
  description = "Whether diagnostic settings are enabled"
  value       = var.enable_diagnostics
}

# Resource Information
output "resource_group_name" {
  description = "The resource group name where AKS cluster is deployed"
  value       = var.resource_group_name
}

output "location" {
  description = "The Azure region where AKS cluster is deployed"
  value       = var.location
}

# Load Balancer outputs
output "internal_load_balancer_id" {
  description = "Internal load balancer ID (if created)"
  value       = var.service_exposure_type == "LoadBalancer" && var.create_internal_load_balancer && var.existing_load_balancer_id == "" ? azurerm_lb.internal[0].id : null
}

output "internal_load_balancer_frontend_ip" {
  description = "Internal load balancer frontend IP (if created)"
  value       = var.service_exposure_type == "LoadBalancer" && var.create_internal_load_balancer && var.existing_load_balancer_id == "" ? azurerm_lb.internal[0].frontend_ip_configuration[0].private_ip_address : null
}

# Service Exposure Configuration
output "service_exposure_type" {
  description = "Service exposure type configured"
  value       = var.service_exposure_type
}

# Log Storage Configuration
output "log_storage_type" {
  description = "Log storage type configured"
  value       = var.log_storage_type
}

output "log_analytics_enabled" {
  description = "Whether Log Analytics is enabled for logs"
  value       = var.log_storage_type == "log_analytics" || var.log_storage_type == "both"
}

output "storage_account_enabled" {
  description = "Whether Storage Account is enabled for logs"
  value       = var.log_storage_type == "storage_account" || var.log_storage_type == "both"
}

# Enterprise Features Outputs
output "workload_identity_enabled" {
  description = "Whether Workload Identity is enabled"
  value       = var.enable_workload_identity
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for Workload Identity"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "defender_enabled" {
  description = "Whether Microsoft Defender for Containers is enabled"
  value       = var.enable_defender_for_containers
}

output "backup_enabled" {
  description = "Whether AKS backup is enabled"
  value       = var.enable_backup && var.backup_vault_id != "" && var.backup_policy_id != ""
}

# NAT Gateway outputs
output "nat_gateway_enabled" {
  description = "Whether NAT Gateway is enabled"
  value       = var.enable_nat_gateway
}

output "nat_gateway_id" {
  description = "NAT Gateway ID (if created)"
  value       = var.enable_nat_gateway && var.create_nat_gateway && var.existing_nat_gateway_id == "" ? azurerm_nat_gateway.aks[0].id : var.existing_nat_gateway_id
}

output "nat_gateway_public_ips" {
  description = "NAT Gateway public IP addresses (if created)"
  value       = var.enable_nat_gateway && var.create_nat_gateway && var.existing_nat_gateway_id == "" ? [for ip in azurerm_public_ip.nat_gateway : ip.ip_address] : []
}

# Private Endpoints outputs
output "private_endpoints_enabled" {
  description = "Whether private endpoints are enabled"
  value       = var.enable_private_endpoints
}

output "private_endpoint_ids" {
  description = "Private endpoint IDs (if created)"
  value = {
    acr_private_endpoint_id           = var.enable_private_endpoints && var.create_private_endpoints && var.existing_private_endpoints.acr_private_endpoint_id == "" && var.dependency_resource_ids.acr_registry_id != "" ? azurerm_private_endpoint.acr[0].id : var.existing_private_endpoints.acr_private_endpoint_id
    key_vault_private_endpoint_id     = var.enable_private_endpoints && var.create_private_endpoints && var.existing_private_endpoints.key_vault_private_endpoint_id == "" && var.dependency_resource_ids.key_vault_id != "" ? azurerm_private_endpoint.key_vault[0].id : var.existing_private_endpoints.key_vault_private_endpoint_id
    log_analytics_private_endpoint_id = var.enable_private_endpoints && var.create_private_endpoints && var.existing_private_endpoints.log_analytics_private_endpoint_id == "" && var.dependency_resource_ids.log_analytics_workspace_id != "" ? azurerm_private_endpoint.log_analytics[0].id : var.existing_private_endpoints.log_analytics_private_endpoint_id
    storage_private_endpoint_id       = var.enable_private_endpoints && var.create_private_endpoints && var.existing_private_endpoints.storage_private_endpoint_id == "" && var.dependency_resource_ids.storage_account_id != "" ? azurerm_private_endpoint.storage[0].id : var.existing_private_endpoints.storage_private_endpoint_id
  }
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs (if created)"
  value = {
    acr_dns_zone_id           = var.enable_private_endpoints && var.create_private_dns_zones && var.existing_private_dns_zone_ids.acr_dns_zone_id == "" && var.dependency_resource_ids.acr_registry_id != "" ? azurerm_private_dns_zone.acr[0].id : var.existing_private_dns_zone_ids.acr_dns_zone_id
    key_vault_dns_zone_id     = var.enable_private_endpoints && var.create_private_dns_zones && var.existing_private_dns_zone_ids.key_vault_dns_zone_id == "" && var.dependency_resource_ids.key_vault_id != "" ? azurerm_private_dns_zone.key_vault[0].id : var.existing_private_dns_zone_ids.key_vault_dns_zone_id
    log_analytics_dns_zone_id = var.enable_private_endpoints && var.create_private_dns_zones && var.existing_private_dns_zone_ids.log_analytics_dns_zone_id == "" && var.dependency_resource_ids.log_analytics_workspace_id != "" ? azurerm_private_dns_zone.log_analytics[0].id : var.existing_private_dns_zone_ids.log_analytics_dns_zone_id
    storage_dns_zone_id       = var.enable_private_endpoints && var.create_private_dns_zones && var.existing_private_dns_zone_ids.storage_dns_zone_id == "" && var.dependency_resource_ids.storage_account_id != "" ? azurerm_private_dns_zone.storage[0].id : var.existing_private_dns_zone_ids.storage_dns_zone_id
  }
}

# High Availability outputs
output "availability_zones_enabled" {
  description = "Whether availability zones are enabled"
  value       = var.enable_availability_zones
}

output "cluster_availability_zones" {
  description = "Availability zones configured for the cluster"
  value       = var.enable_availability_zones ? var.cluster_availability_zones : []
}

# Disk Encryption outputs
output "disk_encryption_set_enabled" {
  description = "Whether disk encryption set is configured"
  value       = var.use_existing_disk_encryption_set || var.key_vault_key_id != ""
}

output "disk_encryption_set_id" {
  description = "Disk encryption set ID being used"
  value       = var.use_existing_disk_encryption_set ? var.existing_disk_encryption_set_id : (var.key_vault_key_id != "" ? azurerm_disk_encryption_set.aks[0].id : null)
}

# Policy Assignments outputs
output "kubernetes_policy_assignments_enabled" {
  description = "Whether Kubernetes policy assignments are enabled"
  value       = var.enable_kubernetes_policy_assignments
}

output "kubernetes_policy_assignment_ids" {
  description = "Kubernetes policy assignment IDs (if created)"
  value       = var.enable_kubernetes_policy_assignments ? [for assignment in azurerm_resource_policy_assignment.kubernetes_policies : assignment.id] : []
}

# Complete AKS Cluster Object (for advanced use cases)
output "aks_cluster" {
  description = "The complete AKS cluster resource object"
  value       = azurerm_kubernetes_cluster.aks
  sensitive   = true
}
