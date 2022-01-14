resource "azurerm_resource_group" "rg-central-us-gecko-t" {
  name     = "rg-central-us-gecko-t"
  location = "Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-central-us-gecko-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sacentralusgeckot" {
  name                     = "sacentralusgeckot"
  resource_group_name      = azurerm_resource_group.rg-central-us-gecko-t.name
  location                 = "Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sacentralusgeckot"
    })
  )
}
resource "azurerm_network_security_group" "nsg-central-us-gecko-t" {
  name                = "nsg-central-us-gecko-t"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.rg-central-us-gecko-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-central-us-gecko-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-central-us-gecko-t" {
  name                = "vn-central-us-gecko-t"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.rg-central-us-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-central-us-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-central-us-gecko-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-central-us-gecko-t"
    })
  )
}

resource "azurerm_resource_group" "rg-east-us-2-gecko-t" {
  name     = "rg-east-us-2-gecko-t"
  location = "East US 2"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-east-us-2-gecko-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "saeastus2geckot" {
  name                     = "saeastus2geckot"
  resource_group_name      = azurerm_resource_group.rg-east-us-2-gecko-t.name
  location                 = "East US 2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "saeastus2geckot"
    })
  )
}
resource "azurerm_network_security_group" "nsg-east-us-2-gecko-t" {
  name                = "nsg-east-us-2-gecko-t"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.rg-east-us-2-gecko-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-east-us-2-gecko-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-east-us-2-gecko-t" {
  name                = "vn-east-us-2-gecko-t"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.rg-east-us-2-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-east-us-2-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-east-us-2-gecko-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-east-us-2-gecko-t"
    })
  )
}

resource "azurerm_resource_group" "rg-east-us-gecko-t" {
  name     = "rg-east-us-gecko-t"
  location = "East US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-east-us-gecko-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "saeastusgeckot" {
  name                     = "saeastusgeckot"
  resource_group_name      = azurerm_resource_group.rg-east-us-gecko-t.name
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "saeastusgeckot"
    })
  )
}
resource "azurerm_network_security_group" "nsg-east-us-gecko-t" {
  name                = "nsg-east-us-gecko-t"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg-east-us-gecko-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-east-us-gecko-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-east-us-gecko-t" {
  name                = "vn-east-us-gecko-t"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg-east-us-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-east-us-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-east-us-gecko-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-east-us-gecko-t"
    })
  )
}

resource "azurerm_resource_group" "rg-north-central-us-gecko-t" {
  name     = "rg-north-central-us-gecko-t"
  location = "North Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-north-central-us-gecko-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sanorthcentralusgeckot" {
  name                     = "sanorthcentralusgeckot"
  resource_group_name      = azurerm_resource_group.rg-north-central-us-gecko-t.name
  location                 = "North Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sanorthcentralusgeckot"
    })
  )
}
resource "azurerm_network_security_group" "nsg-north-central-us-gecko-t" {
  name                = "nsg-north-central-us-gecko-t"
  location            = "North Central US"
  resource_group_name = azurerm_resource_group.rg-north-central-us-gecko-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-north-centra-us-gecko-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-north-central-us-gecko-t" {
  name                = "vn-north-central-us-gecko-t"
  location            = "North Central US"
  resource_group_name = azurerm_resource_group.rg-north-central-us-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-north-central-us-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-north-central-us-gecko-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-north-central-us-gecko-t"
    })
  )
}

resource "azurerm_resource_group" "rg-north-europe-gecko-t" {
  name     = "rg-north-europe-gecko-t"
  location = "North Europe"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-north-europe-gecko-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sanortheuropegeckot" {
  name                     = "sanortheuropegeckot"
  resource_group_name      = azurerm_resource_group.rg-north-europe-gecko-t.name
  location                 = "North Europe"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sanortheuropegeckot"
    })
  )
}
resource "azurerm_network_security_group" "nsg-north-europe-gecko-t" {
  name                = "nsg-north-europe-gecko-t"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.rg-north-europe-gecko-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-north-europe-gecko-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-north-europe-gecko-t" {
  name                = "vn-north-europe-gecko-t"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.rg-north-europe-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-north-europe-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-north-europe-gecko-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-north-europe-gecko-t"
    })
  )
}

resource "azurerm_resource_group" "rg-south-central-us-gecko-t" {
  name     = "rg-south-central-us-gecko-t"
  location = "South Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-south-central-us-gecko-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sasouthcentralusgeckot" {
  name                     = "sasouthcentralusgeckot"
  resource_group_name      = azurerm_resource_group.rg-south-central-us-gecko-t.name
  location                 = "South Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sasouthcentralusgeckot"
    })
  )
}
resource "azurerm_network_security_group" "nsg-south-central-us-gecko-t" {
  name                = "nsg-south-central-us-gecko-t"
  location            = "South Central US"
  resource_group_name = azurerm_resource_group.rg-south-central-us-gecko-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-south-central-us-gecko-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-south-central-us-gecko-t" {
  name                = "vn-south-central-us-gecko-t"
  location            = "South Central US"
  resource_group_name = azurerm_resource_group.rg-south-central-us-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-south-central-us-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-south-central-us-gecko-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-south-central-us-gecko-t"
    })
  )
}

resource "azurerm_resource_group" "rg-west-europe-gecko-t" {
  name     = "rg-west-europe-gecko-t"
  location = "West Europe"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-west-europe-gecko-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sawesteuropegeckot" {
  name                     = "sawesteuropegeckot"
  resource_group_name      = azurerm_resource_group.rg-west-europe-gecko-t.name
  location                 = "West Europe"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sawesteuropegeckot"
    })
  )
}
resource "azurerm_network_security_group" "nsg-west-europe-gecko-t" {
  name                = "nsg-west-europe-gecko-t"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg-west-europe-gecko-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-west-europe-gecko-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-west-europe-gecko-t" {
  name                = "vn-west-europe-gecko-t"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg-west-europe-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-west-europe-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-west-europe-gecko-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-west-europe-gecko-t"
    })
  )
}

resource "azurerm_resource_group" "rg-west-us-2-gecko-t" {
  name     = "rg-west-us-2-gecko-t"
  location = "West US 2"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-west-us-2-gecko-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sawestus2geckot" {
  name                     = "sawest2usgeckot"
  resource_group_name      = azurerm_resource_group.rg-west-us-2-gecko-t.name
  location                 = "West US 2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sawest2usgeckot"
    })
  )
}
resource "azurerm_network_security_group" "nsg-west-us2-gecko-t" {
  name                = "nsg-west-us2-gecko-t"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.rg-west-us-2-gecko-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-west-us2-gecko-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-west-us2-gecko-t" {
  name                = "vn-west-us-2-gecko-t"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.rg-west-us-2-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-west-us-2-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-west-us2-gecko-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-west-us-2-gecko-t"
    })
  )
}

resource "azurerm_resource_group" "rg-west-us-gecko-t" {
  name     = "rg-west-us-gecko-t"
  location = "West US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-west-us-gecko-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sawestusgeckot" {
  name                     = "sawestusgeckot"
  resource_group_name      = azurerm_resource_group.rg-west-us-gecko-t.name
  location                 = "West US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sawestusgeckot"
    })
  )
}
resource "azurerm_network_security_group" "nsg-west-us-gecko-t" {
  name                = "nsg-west-us-gecko-t"
  location            = "West US"
  resource_group_name = azurerm_resource_group.rg-west-us-gecko-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-west-us-gecko-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-west-us-gecko-t" {
  name                = "vn-west-us-gecko-t"
  location            = "West US"
  resource_group_name = azurerm_resource_group.rg-west-us-gecko-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-west-us-gecko-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-west-us-gecko-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-west-us-gecko-t"
    })
  )
}
