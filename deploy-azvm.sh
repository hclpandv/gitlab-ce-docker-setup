export RESOURCE_GROUP_NAME="rg-module-test-01"
export REGION="westeurope"
export VM_NAME="linvm01"
export USERNAME="azureadmin"
export VM_SIZE="Standard_B2s"

# rg
az group create --name $RESOURCE_GROUP_NAME --location $REGION

# virtual network
az network vnet create --resource-group $RESOURCE_GROUP_NAME --name "$VM_NAME-vnet" --address-prefix "192.168.0.0/16" \
    --location $REGION \
    --subnet-name "GL-subnet" --subnet-prefix "192.168.1.0/24"

# Public IP
az network public-ip create --resource-group $RESOURCE_GROUP_NAME  --name "$VM_NAME-pip"

# network security group
az network nsg create --resource-group $RESOURCE_GROUP_NAME  --name "$VM_NAME-nsg"

# Nic
az network nic create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name "$VM_NAME-nic" \
  --vnet-name "$VM_NAME-vnet" \
  --subnet "GL-subnet" \
  --network-security-group "$VM_NAME-nsg" \
  --public-ip-address "$VM_NAME-pip"

# vm
az vm create --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --nics "$VM_NAME-nic" --image Ubuntu2204 --generate-ssh-keys \
  --size $VM_SIZE \
  --admin-username $USERNAME \

# Open port 22 to allow SSh traffic to host.
az vm open-port --port 22 --priority 100 --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME

# Open port 80 to allow http traffic to host.
az vm open-port --port 80 --priority 110 --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME

# Open port 443 to allow http traffic to host.
az vm open-port --port 443 --priority 120 --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME
