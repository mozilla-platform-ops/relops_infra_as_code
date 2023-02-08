resource "azurerm_resource_group" "rg-canada-central-comm-t" {
  name     = "rg-canada-central-comm-t"
  location = "Canada Central"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-canada-central-comm-t"
    })
  )
}

resource "azurerm_storage_account" "sacanadacentralcommt" {
  name                     = "sacanadacentralcommt"
  resource_group_name      = azurerm_resource_group.rg-canada-central-comm-t.name
  location                 = "Canada Central"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sacanadacentralcommt"
    })
  )
}

resource "azurerm_network_security_group" "nsg-canada-central-comm-t" {
  name                = "nsg-canada-central-comm-t"
  location            = "Canada Central"
  resource_group_name = azurerm_resource_group.rg-canada-central-comm-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-canada-central-comm-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-canada-central-comm-t" {
  name                = "vn-canada-central-comm-t"
  location            = "Canada Central"
  resource_group_name = azurerm_resource_group.rg-canada-central-comm-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-canada-central-comm-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-canada-central-comm-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-canada-central-comm-t"
    })
  )
}

## Central India
resource "azurerm_resource_group" "rg-central-india-comm-t" {
  name     = "rg-central-comm-comm-t"
  location = "Central India"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-central-india-comm-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sacentralindiacommt" {
  name                     = "sacentralindiacommt"
  resource_group_name      = azurerm_resource_group.rg-central-india-comm-t.name
  location                 = "Central India"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sacentralindiacommt"
    })
  )
}

resource "azurerm_network_security_group" "nsg-central-india-comm-t" {
  name                = "nsg-central-india-comm-t"
  location            = "Central India"
  resource_group_name = azurerm_resource_group.rg-central-india-comm-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-central-india-comm-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-central-india-comm-t" {
  name                = "vn-central-india-comm-t"
  location            = "Central India"
  resource_group_name = azurerm_resource_group.rg-central-india-comm-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-central-india-comm-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-central-india-comm-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-central-india-comm-t"
    })
  )
}

#
resource "azurerm_resource_group" "rg-central-us-comm-t" {
  name     = "rg-central-us-comm-t"
  location = "Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-central-us-comm-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sacentraluscommt" {
  name                     = "sacentraluscommt"
  resource_group_name      = azurerm_resource_group.rg-central-us-comm-t.name
  location                 = "Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sacentraluscommt"
    })
  )
}
resource "azurerm_network_security_group" "nsg-central-us-comm-t" {
  name                = "nsg-central-us-comm-t"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.rg-central-us-comm-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-central-us-comm-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-central-us-comm-t" {
  name                = "vn-central-us-comm-t"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.rg-central-us-comm-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-central-us-comm-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-central-us-comm-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-central-us-comm-t"
    })
  )
}

resource "azurerm_resource_group" "rg-east-us-2-comm-t" {
  name     = "rg-east-us-2-comm-t"
  location = "East US 2"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-east-us-2-comm-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "saeastus2commt" {
  name                     = "saeastus2commt"
  resource_group_name      = azurerm_resource_group.rg-east-us-2-comm-t.name
  location                 = "East US 2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "saeastus2commt"
    })
  )
}
resource "azurerm_network_security_group" "nsg-east-us-2-comm-t" {
  name                = "nsg-east-us-2-comm-t"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.rg-east-us-2-comm-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-east-us-2-comm-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-east-us-2-comm-t" {
  name                = "vn-east-us-2-comm-t"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.rg-east-us-2-comm-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-east-us-2-comm-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-east-us-2-comm-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-east-us-2-comm-t"
    })
  )
}

resource "azurerm_resource_group" "rg-east-us-comm-t" {
  name     = "rg-east-us-comm-t"
  location = "East US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-east-us-comm-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "saeastuscommt" {
  name                     = "saeastuscommt"
  resource_group_name      = azurerm_resource_group.rg-east-us-comm-t.name
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "saeastuscommt"
    })
  )
}
resource "azurerm_network_security_group" "nsg-east-us-comm-t" {
  name                = "nsg-east-us-comm-t"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg-east-us-comm-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-east-us-comm-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-east-us-comm-t" {
  name                = "vn-east-us-comm-t"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg-east-us-comm-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-east-us-comm-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-east-us-comm-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-east-us-comm-t"
    })
  )
}

resource "azurerm_resource_group" "rg-north-central-us-comm-t" {
  name     = "rg-north-central-us-comm-t"
  location = "North Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-north-central-us-comm-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sanorthcentraluscommt" {
  name                     = "sanorthcentraluscommt"
  resource_group_name      = azurerm_resource_group.rg-north-central-us-comm-t.name
  location                 = "North Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sanorthcentraluscommt"
    })
  )
}
resource "azurerm_network_security_group" "nsg-north-central-us-comm-t" {
  name                = "nsg-north-central-us-comm-t"
  location            = "North Central US"
  resource_group_name = azurerm_resource_group.rg-north-central-us-comm-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-north-centra-us-comm-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-north-central-us-comm-t" {
  name                = "vn-north-central-us-comm-t"
  location            = "North Central US"
  resource_group_name = azurerm_resource_group.rg-north-central-us-comm-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-north-central-us-comm-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-north-central-us-comm-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-north-central-us-comm-t"
    })
  )
}

resource "azurerm_resource_group" "rg-south-central-us-comm-t" {
  name     = "rg-south-central-us-comm-t"
  location = "South Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-south-central-us-comm-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sasouthcentraluscommt" {
  name                     = "sasouthcentraluscommt"
  resource_group_name      = azurerm_resource_group.rg-south-central-us-comm-t.name
  location                 = "South Central US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sasouthcentraluscommt"
    })
  )
}
resource "azurerm_network_security_group" "nsg-south-central-us-comm-t" {
  name                = "nsg-south-central-us-comm-t"
  location            = "South Central US"
  resource_group_name = azurerm_resource_group.rg-south-central-us-comm-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-south-central-us-comm-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-south-central-us-comm-t" {
  name                = "vn-south-central-us-comm-t"
  location            = "South Central US"
  resource_group_name = azurerm_resource_group.rg-south-central-us-comm-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-south-central-us-comm-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-south-central-us-comm-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-south-central-us-comm-t"
    })
  )
}

resource "azurerm_resource_group" "rg-west-us-2-comm-t" {
  name     = "rg-west-us-2-comm-t"
  location = "West US 2"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-west-us-2-comm-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sawestus2commt" {
  name                     = "sawest2uscommt"
  resource_group_name      = azurerm_resource_group.rg-west-us-2-comm-t.name
  location                 = "West US 2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sawest2uscommt"
    })
  )
}
resource "azurerm_network_security_group" "nsg-west-us2-comm-t" {
  name                = "nsg-west-us2-comm-t"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.rg-west-us-2-comm-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-west-us2-comm-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-west-us2-comm-t" {
  name                = "vn-west-us-2-comm-t"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.rg-west-us-2-comm-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-west-us-2-comm-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-west-us2-comm-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-west-us-2-comm-t"
    })
  )
}

resource "azurerm_resource_group" "rg-west-us-3-comm-t" {
  name     = "rg-west-us-3-comm-t"
  location = "West US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-west-us-3-comm-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sawestus3commt" {
  name                     = "sawestus3commt"
  resource_group_name      = azurerm_resource_group.rg-west-us-3-comm-t.name
  location                 = "West US 3"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sawestus3commt"
    })
  )
}
resource "azurerm_network_security_group" "nsg-west-us-3-comm-t" {
  name                = "nsg-west-us-3-comm-t"
  location            = "West US 3"
  resource_group_name = azurerm_resource_group.rg-west-us-3-comm-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-west-us-3-comm-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-west-us-3-comm-t" {
  name                = "vn-west-us-3-comm-t"
  location            = "West US 3"
  resource_group_name = azurerm_resource_group.rg-west-us-3-comm-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-west-us-3-comm-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-west-us-3-comm-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-west-us-3-comm-t"
    })
  )
}

resource "azurerm_resource_group" "rg-west-us-comm-t" {
  name     = "rg-west-us-comm-t"
  location = "West US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-west-us-comm-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sawestuscommt" {
  name                     = "sawestuscommt"
  resource_group_name      = azurerm_resource_group.rg-west-us-comm-t.name
  location                 = "West US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sawestuscommt"
    })
  )
}
resource "azurerm_network_security_group" "nsg-west-us-comm-t" {
  name                = "nsg-west-us-comm-t"
  location            = "West US"
  resource_group_name = azurerm_resource_group.rg-west-us-comm-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-west-us-comm-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-west-us-comm-t" {
  name                = "vn-west-us-comm-t"
  location            = "West US"
  resource_group_name = azurerm_resource_group.rg-west-us-comm-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-west-us-comm-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-west-us-comm-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-west-us-comm-t"
    })
  )
}

resource "azurerm_resource_group" "rg-south-india-comm-t" {
  name     = "rg-south-india-comm-t"
  location = "South India"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-south-india-comm-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sasouthindiacommt" {
  name                     = "sasouthindiacommt"
  resource_group_name      = azurerm_resource_group.rg-south-india-comm-t.name
  location                 = "South India"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sasouthindiacommt"
    })
  )
}
resource "azurerm_network_security_group" "nsg-south-india-comm-t" {
  name                = "nsg-south-india-comm-t"
  location            = "South India"
  resource_group_name = azurerm_resource_group.rg-south-india-comm-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-south-india-comm-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-south-india-comm-t" {
  name                = "vn-south-india-comm-t"
  location            = "South India"
  resource_group_name = azurerm_resource_group.rg-south-india-comm-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-south-india-comm-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-south-india-comm-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-south-india-comm-t"
    })
  )
}

resource "azurerm_resource_group" "rg-north-europe-comm-t" {
  name     = "rg-north-europe-comm-t"
  location = "North Europe"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-north-europe-comm-t"
    })
  )
}
# storage account names can only consist of lowercase letters and numbers
resource "azurerm_storage_account" "sanortheuropecommt" {
  name                     = "sanortheuropecommt"
  resource_group_name      = azurerm_resource_group.rg-north-europe-comm-t.name
  location                 = "North Europe"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "sanortheuropecommt"
    })
  )
}
resource "azurerm_network_security_group" "nsg-North-Europe-comm-t" {
  name                = "nsg-north-europe-comm-t"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.rg-north-europe-comm-t.name
  tags = merge(local.common_tags,
    tomap({
      "Name" = "nsg-north-europe-comm-t"
    })
  )
}
resource "azurerm_virtual_network" "vn-north-europe-comm-t" {
  name                = "vn-north-europe-comm-t"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.rg-north-europe-comm-t.name
  address_space       = ["10.0.0.0/24"]
  dns_servers         = ["1.1.1.1", "1.1.1.0"]
  subnet {
    name           = "sn-north-europe-comm-t"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg-north-europe-comm-t.id
  }
  tags = merge(local.common_tags,
    tomap({
      "Name" = "vn-north-europe-comm-t"
    })
  )
}