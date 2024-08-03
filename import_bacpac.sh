#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Debugging information
echo "SQL Server: $SQL_SERVER"
echo "SQL Database: $SQL_DATABASE"
echo "Resource Group: $RESOURCE_GROUP"
echo "Admin User: $ADMIN_USER"
echo "AdventureWorks Bacpac: $ADVENTUREWORKS_BACPAC"

# Get the storage account key
echo "Retrieving storage account key..."
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query '[0].value' --output tsv)

if [ -z "$STORAGE_KEY" ]; then
  echo "Failed to retrieve storage account key"
  exit 1
fi

echo "Storage Key: $STORAGE_KEY"

# Create a firewall rule to allow Azure services to access the SQL Server
echo "Creating firewall rule to allow Azure services to access the SQL Server..."
az sql server firewall-rule create --resource-group $RESOURCE_GROUP --server $SQL_SERVER --name AllowAllAzure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

# Import the AdventureWorks bacpac to the SQL Database
echo "Importing $ADVENTUREWORKS_BACPAC to the SQL Database..."
az sql db import -s $SQL_SERVER -n $SQL_DATABASE -g $RESOURCE_GROUP --admin-user $ADMIN_USER --admin-password $ADMIN_PASSWORD --storage-key $STORAGE_KEY --storage-key-type StorageAccessKey --storage-uri "https://$STORAGE_ACCOUNT.blob.core.windows.net/$CONTAINER_NAME/$ADVENTUREWORKS_BACPAC"
