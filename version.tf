# =============================================================================
# TERRAFORM VERSION AND PROVIDER REQUIREMENTS
# =============================================================================
# Define minimum Terraform version and required providers for AKS module
# Ensures compatibility and feature availability across deployments

terraform {
  # Minimum Terraform version required for this module
  required_version = ">= 1.0"

  # Required providers with version constraints
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"  # Official Azure provider
      version = "~> 4.0"             # Compatible with AzureRM 4.x
    }
  }
}