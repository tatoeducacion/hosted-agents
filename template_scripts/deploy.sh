# Config variables
agent_image_name = "agentframework_mcp"
agent_image_version = "v1"

conainer_registry_name = "agentscr"


# Install Az CLI and login to the container registry
## ONLY NEEDED ONCE per foundry project
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az acr login --name $conainer_registry_name
TOKEN=$(az account get-access-token --resource https://management.azure.com/ --query accessToken -o tsv)
curl --request PUT \
  --url 'https://management.azure.com/subscriptions/[SUBSCRIPTIONID]/resourceGroups/[RESOURCEGROUPNAME]/providers/Microsoft.CognitiveServices/accounts/[ACCOUNTNAME]/capabilityHosts/accountcaphost?api-version=2025-10-01-preview' \
  --header 'content-type: application/json' \
  --header "authorization: Bearer $TOKEN"\
  --data '{
  "properties": {
    "capabilityHostKind": "Agents",
    "enablePublicHostingEnvironment": true
    }
}'


# Build and deploy container image
docker build -t $agent_image_name:$agent_image_version .
docker tag $agent_image_name:$agent_image_version $conainer_registry_name.azurecr.io/$agent_image_name:$agent_image_version
docker push $conainer_registry_name.azurecr.io/$agent_image_name:$agent_image_version
