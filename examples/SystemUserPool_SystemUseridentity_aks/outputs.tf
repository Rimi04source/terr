# =============================================================================
# PRODUCTION EXAMPLE OUTPUTS
# =============================================================================

# Cluster Information
output "cluster_id" {
  description = "AKS cluster ID"
  value       = module.systemuserpool_userassignedidentity_aks.aks_cluster_id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = module.systemuserpool_userassignedidentity_aks.aks_cluster_name
}

output "cluster_fqdn" {
  description = "AKS cluster FQDN"
  value       = module.systemuserpool_userassignedidentity_aks.aks_cluster_fqdn
}

output "cluster_private_fqdn" {
  description = "AKS cluster private FQDN"
  value       = module.systemuserpool_userassignedidentity_aks.aks_private_fqdn
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
output "user_node_pools" {
  description = "User node pool IDs"
  value       = module.systemuserpool_userassignedidentity_aks.user_node_pool_ids
}

# Network Information
output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.systemuserpool_userassignedidentity_aks.nat_gateway_id
}

output "private_endpoint_ids" {
  description = "Private endpoint IDs"
  value       = module.systemuserpool_userassignedidentity_aks.private_endpoint_ids
}

output "load_balancer_id" {
  description = "Internal load balancer ID"
  value       = module.systemuserpool_userassignedidentity_aks.internal_load_balancer_id
}

# Security Information
output "disk_encryption_set_id" {
  description = "Disk encryption set ID"
  value       = module.systemuserpool_userassignedidentity_aks.disk_encryption_set_id
}

# Configuration Status
output "availability_zones" {
  description = "Availability zones configuration"
  value       = module.systemuserpool_userassignedidentity_aks.cluster_availability_zones
}

output "availability_zones" {
  description = "Availability zones configuration"
  value       = module.systemuserpool_userassignedidentity_aks.availability_zones
}

output "maintenance_window_enabled" {
  description = "Maintenance window status"
  value       = module.systemuserpool_userassignedidentity_aks.maintenance_window_enabled
}
