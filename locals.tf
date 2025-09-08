# =============================================================================
# LOCAL VALUES AND COMPUTED CONFIGURATIONS
# =============================================================================
# Define local values for resource naming, tagging, and configuration logic
# that will be reused throughout the module

locals {
  # Cluster naming with optional prefix
  cluster_name = var.resource_prefix != null ? "${var.resource_prefix}-${var.aks_cluster_name}" : var.aks_cluster_name

  # Common tags applied to all resources
  common_tags = merge(
    {
      Environment   = "production"
      ManagedBy     = "terraform"
      Project       = "aks-cluster"
      ClusterName   = local.cluster_name
    },
    var.tags
  )
}