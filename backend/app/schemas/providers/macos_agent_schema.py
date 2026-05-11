from pydantic import BaseModel, model_validator
from datetime import datetime, timedelta
from uuid import UUID


class Port(BaseModel):
    ip: str
    pid: int
    port: int
    status: str


class Network(BaseModel):
    open_ports: list[Port]
    network_packets_sent: int
    network_packets_received: int


class Memory(BaseModel):
    percent: float
    used_gb: float
    total_gb: float


class DiskUsage(BaseModel):
    free: int
    used: int
    total: int
    device: str
    percent: float


class Hardware(BaseModel):
    memory: Memory
    cpu_usage: float
    disks_usage: list[DiskUsage]
    disk_partitions: list[list]


class PowerData(BaseModel):
    battery: list
    boot_time: str  
    uptime: str 

    @model_validator(mode="before")
    @classmethod
    def format_power_data(cls, power_data):
        boot_time_seconds = power_data.get("boot_time")
        uptime_seconds = power_data.get("uptime_seconds")

        power_data["boot_time"] = datetime.fromtimestamp(boot_time_seconds).strftime("%Y-%m-%d %H:%M:%S")
        power_data["uptime"] = str(timedelta(seconds=uptime_seconds))

        return power_data


class SystemData(BaseModel):
    system: str
    release: str
    version: str
    platform: str


class AgentData(BaseModel):
    users: list[str]
    network: Network
    hardware: Hardware
    power_data: PowerData
    system_data: SystemData

class AgentInformation(BaseModel):
    agent_id: UUID
    created_at: datetime
    agent_data: AgentData


class MacOSAgentResponse(BaseModel):
    count: int
    items: list[AgentInformation]
