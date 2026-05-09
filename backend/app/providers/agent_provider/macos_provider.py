from app.repositories.interfaces.providers_interface import IProvidersRepository
import app.repositories.metrics_repository as mr
from app.schemas.providers.agent_schema import AgentResponse, MetricItem


class MacOSProvider():
    PROVIDER_NAME = "macos"

    def __init__(self, repository: IProvidersRepository):
        self.repository = repository

    async def fetch_provider_data(self, data_type: str, data_config: dict):
        raw = mr.listar_metricas_por_resource_type_y_tipo_agente(data_type, self.PROVIDER_NAME)
        items = [MetricItem(**m) for m in raw]
        return AgentResponse(count=len(items), items=items).model_dump()

