# =============================================================================
# PRODUCTION EXAMPLE OUTPUTS
# =============================================================================

# Cluster Information
output "cluster_id" {
  description = "AKS cluster ID"
  value       = module.systemuserpool_userassignedidentity_aks.cluster_id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = module.systemuserpool_userassignedidentity_aks.cluster_name
}

output "cluster_fqdn" {
  description = "AKS cluster FQDN"
  value       = module.systemuserpool_userassignedidentity_aks.cluster_fqdn
}

output "cluster_private_fqdn" {
  description = "AKS cluster private FQDN"
  value       = module.systemuserpool_userassignedidentity_aks.cluster_private_fqdn
}

# Identity Information
output "cluster_identity" {
  description = "AKS cluster identity"
  value       = module.systemuserpool_userassignedidentity_aks.cluster_identity
}

output "user_assigned_identity_id" {
  description = "User assigned identity ID"
  value       = module.systemuserpool_userassignedidentity_aks.user_assigned_identity_id
}

# Node Pool Information
output "node_pools" {
  description = "Node pool information"
  value       = module.systemuserpool_userassignedidentity_aks.node_pools
}

# Network Information
output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.systemuserpool_userassignedidentity_aks.nat_gateway_ids
}

output "private_endpoint_ids" {
  description = "Private endpoint IDs"
  value       = module.systemuserpool_userassignedidentity_aks.private_endpoint_ids
}

output "load_balancer_id" {
  description = "Load balancer ID"
  value       = module.systemuserpool_userassignedidentity_aks.load_balancer_id
}

# Security Information
output "disk_encryption_set_id" {
  description = "Disk encryption set ID"
  value       = module.systemuserpool_userassignedidentity_aks.disk_encryption_set_id
}

# Configuration Status
output "private_cluster_enabled" {
  description = "Private cluster status"
  value       = module.systemuserpool_userassignedidentity_aks.private_cluster_enabled
}

output "availability_zones" {
  description = "Availability zones configuration"
  value       = module.systemuserpool_userassignedidentity_aks.availability_zones
}

output "maintenance_window_enabled" {
  description = "Maintenance window status"
  value       = module.systemuserpool_userassignedidentity_aks.maintenance_window_enabled
}