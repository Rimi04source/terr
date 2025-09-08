# =============================================================================
# OUTPUTS
# =============================================================================

# AKS Cluster outputs
output "aks_cluster_id" {
  description = "AKS cluster ID"
  value       = module.systempool_systemidentity_aks.aks_cluster_id
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = module.systempool_systemidentity_aks.aks_cluster_name
}

output "aks_cluster_fqdn" {
  description = "AKS cluster FQDN"
  value       = module.systempool_systemidentity_aks.aks_cluster_fqdn
}

output "aks_private_fqdn" {
  description = "AKS cluster private FQDN"
  value       = module.systempool_systemidentity_aks.aks_private_fqdn
}

# Identity outputs
output "cluster_identity" {
  description = "AKS cluster managed identity"
  value       = module.systempool_systemidentity_aks.cluster_identity
}

output "kubelet_identity" {
  description = "AKS cluster kubelet identity"
  value       = module.systempool_systemidentity_aks.kubelet_identity
}

# Node Pool outputs
output "node_resource_group" {
  description = "The auto-generated resource group for AKS resources"
  value       = module.systempool_systemidentity_aks.node_resource_group
}

output "system_node_pool_name" {
  description = "System node pool name"
  value       = module.systempool_systemidentity_aks.system_node_pool_name
}

# Network outputs
output "network_profile" {
  description = "AKS cluster network profile"
  value       = module.systempool_systemidentity_aks.network_profile
}

# Diagnostic Settings Output
output "diagnostics_enabled" {
  description = "Whether diagnostic settings are enabled"
  value       = module.systempool_systemidentity_aks.diagnostics_enabled
}

# Resource Information
output "resource_group_name" {
  description = "The resource group name where AKS cluster is deployed"
  value       = module.systempool_systemidentity_aks.resource_group_name
}

output "location" {
  description = "The Azure region where AKS cluster is deployed"
  value       = module.systempool_systemidentity_aks.location
}

# Log Storage Configuration
output "log_storage_type" {
  description = "Log storage type configured"
  value       = module.systempool_systemidentity_aks.log_storage_type
}

output "storage_account_enabled" {
  description = "Whether Storage Account is enabled for logs"
  value       = module.systempool_systemidentity_aks.storage_account_enabled
}

# Enterprise Features Outputs
output "workload_identity_enabled" {
  description = "Whether Workload Identity is enabled"
  value       = module.systempool_systemidentity_aks.workload_identity_enabled
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for Workload Identity"
  value       = module.systempool_systemidentity_aks.oidc_issuer_url
}

# High Availability outputs
output "availability_zones_enabled" {
  description = "Whether availability zones are enabled"
  value       = module.systempool_systemidentity_aks.availability_zones_enabled
}

output "cluster_availability_zones" {
  description = "Availability zones configured for the cluster"
  value       = module.systempool_systemidentity_aks.cluster_availability_zones
}

# Disk Encryption outputs
output "disk_encryption_set_enabled" {
  description = "Whether disk encryption set is configured"
  value       = module.systempool_systemidentity_aks.disk_encryption_set_enabled
}

output "disk_encryption_set_id" {
  description = "Disk encryption set ID being used"
  value       = module.systempool_systemidentity_aks.disk_encryption_set_id
}