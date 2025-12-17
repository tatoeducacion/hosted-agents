import os
from dotenv import load_dotenv

from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import ImageBasedHostedAgentDefinition, ProtocolVersionRecord, AgentProtocol
from azure.identity import DefaultAzureCredential

load_dotenv()
assert os.environ.get("AI_FOUNDRY_API_KEY"), "The 'AI_FOUNDRY_API_KEY' environment variable is not set"

# Config variables
endpoint = "https://fondry-project-resource.services.ai.azure.com/api/projects/fondry-project"
agent_name = "agent-framework-mcp"
cpu = "0.5"
memory = "1Gi"
container_registry_name = "agentstestcr"
agent_image_name = "agent_framework_mcp"
agent_image_version = "v1"
model_name = "gpt-5-nano"
other_settings = {}

# Initialize the client
client = AIProjectClient(
    endpoint=endpoint,
    credential=DefaultAzureCredential()
)

# Create the agent from a container image
agent = client.agents.create_version(
    agent_name=agent_name,
    definition=ImageBasedHostedAgentDefinition(
        container_protocol_versions=[ProtocolVersionRecord(protocol=AgentProtocol.RESPONSES, version="v1")],
        cpu=cpu,
        memory=memory,
        image=f"{container_registry_name}.azurecr.io/{agent_image_name}:{agent_image_version}",
        environment_variables={
            "AZURE_AI_PROJECT_ENDPOINT": endpoint,
            "API_KEY": os.environ["AI_FOUNDRY_API_KEY"],
            "MODEL_NAME": model_name,
            **other_settings,
        }
    )
)