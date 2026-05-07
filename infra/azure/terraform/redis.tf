#-- Definición de la Redis Caché

resource "azurerm_redis_cache" "default" {
  name                 = "autokratech-cache"
  location             = azurerm_resource_group.default.location
  resource_group_name  = azurerm_resource_group.default.name
  capacity             = 2
  family               = "C"
  sku_name             = "Standard"
  non_ssl_port_enabled = false
  minimum_tls_version  = "1.2"

  redis_configuration {
  }
}
resource "azurerm_key_vault_secret" "redis_access_key" {
  name         = "REDIS-ACCESS-KEY"
  value        = azurerm_redis_cache.default.primary_access_key
  key_vault_id = azurerm_key_vault.default.id
}
resource "azurerm_key_vault_secret" "redis_url" {
  name         = "REDIS-URL"
  value        = azurerm_redis_cache.default.hostname
  key_vault_id = azurerm_key_vault.default.id
}
resource "azurerm_key_vault_secret" "redis_port" {
  name         = "REDIS-PORT"
  value        = azurerm_redis_cache.default.port
  key_vault_id = azurerm_key_vault.default.id
}
