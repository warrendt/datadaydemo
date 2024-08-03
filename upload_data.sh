#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Debugging information
echo "Container Name: $CONTAINER_NAME"
echo "Storage Account: $STORAGE_ACCOUNT"
echo "Resource Group: $RESOURCE_GROUP"
echo "AdventureWorks URL: $ADVENTUREWORKS_URL"

# Create storage container
echo "Creating storage container..."
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT --auth-mode login

# Get the storage account key
echo "Retrieving storage account key..."
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query '[0].value' --output tsv)

if [ -z "$STORAGE_KEY" ]; then
  echo "Failed to retrieve storage account key"
  exit 1
fi

echo "Storage Key: $STORAGE_KEY"

# Check if AdventureWorks2022.bacpac file exists
if [ ! -f "AdventureWorks2022.bacpac" ]; then
  echo "AdventureWorks2022.bacpac file not found"
  exit 1
fi

# Upload the bacpac to the storage account
echo "Uploading AdventureWorks2022.bacpac to storage account..."
az storage blob upload --account-name $STORAGE_ACCOUNT --container-name $CONTAINER_NAME --name AdventureWorks2022.bacpac --file AdventureWorks2022.bacpac --auth-mode key --account-key $STORAGE_KEY
