#-- Definición de Key Vault

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "default" {
  name                        = "AutokratechKeyVault"
  location                    = azurerm_resource_group.default.location
  resource_group_name         = azurerm_resource_group.default.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
  rbac_authorization_enabled = true
}

output "key_vault_uri" {
  value = azurerm_key_vault.default.vault_uri
}
