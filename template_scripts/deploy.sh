# Config variables
agent_image_name="codespace_01"
agent_image_version="v2"
conainer_registry_name="agentstestcr"


# Install Az CLI and login to the container registry
## ONLY NEEDED ONCE per foundry project
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login --use-device-code
az acr login --name $conainer_registry_name
TOKEN=$(az account get-access-token --resource https://management.azure.com/ --query accessToken -o tsv)
az cognitiveservices account list -o table
curl --request PUT \
  --url 'https://management.azure.com/subscriptions/a6bfd884-310e-4f46-98f9-3f815c821aa6/resourceGroups/Foundry-rg/providers/Microsoft.CognitiveServices/accounts/MyFoundry-Test-02/capabilityHosts/accountcaphost?api-version=2025-10-01-preview' \
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

python ../../template_scripts/create_hosted_agent_version.py