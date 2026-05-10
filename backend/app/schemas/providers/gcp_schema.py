from pydantic import BaseModel, field_serializer, model_validator
from typing import Annotated, Union
import re

class ProjectID(BaseModel):
    projectId : str


class ProjectList(BaseModel):
    projects: list[ProjectID] = []
    
    #Permitir que el modelo sea iterable, necesario para poder realizar las llamadas a todos los
    def __iter__(self):
        return iter(self.projects)
    
    @field_serializer("projects")
    def serialize_projects(self, projects):
        return [project.projectId for project in projects]
    

class ComputeInstance(BaseModel):
    id: str
    name: str
    location: str | None = None
    vm_sku: str 
    disk_size : int | None = None
    os_type: str | None = None
    os_distro: str | None = None
    os_version: str | None = None
    power_status: str | None = None

    @model_validator(mode="before")
    @classmethod
    def get_vm_data(cls, vm_data):
        
        zone = vm_data.get("zone")
        vm_data["location"] = zone.split("/zones/")[1]
        
        vm_type = vm_data.get("machineType")
        vm_data["vm_sku"] = vm_type.split("/machineTypes/")[1]

        vm_data["disk_size"] = vm_data.get("disks")[0].get("diskSizeGb")  #TODO: Contemplar casos en los que pueda haber más de un disco, pero habrá que actualizar Azure también

        licenses = vm_data.get("disks")[0].get("licenses")
        vm_distro = licenses[0].split("/")[-1] #Si no se contemplan más discos, sólo habrá un resultado, así que hasta que no se cambie lo anterior...
        
        if vm_distro.startswith(("ubuntu", "debian", "fedora", "centos")):
            vm_data["os_type"] = "linux"
        elif vm_distro.startswith(("win", "windows")):
            vm_data["os_type"] = "windows"

        vm_data["os_distro"] = vm_distro

        version_matches = re.findall(r'\d+', vm_distro) #Warning! Devuelve una lista, a pesar de que sólo haya un resultado.
        vm_data["os_version"] = version_matches[0] if version_matches else None

        status = vm_data.get("status")
        vm_data["power_status"] = "on" if status in {"RUNNING", "PROVISIONING"} else "off"

        return vm_data


class ComputeInstanceList(BaseModel):
    items: list[ComputeInstance] = []

    @model_validator(mode="before")
    @classmethod
    def get_vms_instances(cls, instances_data: dict):
        instances = []
        for zone_data in instances_data.get("items", {}).values():
            for instance in zone_data.get("instances", []):
                if instance.get("kind") == "compute#instance":
                    instances.append(instance)
        return {"items": instances}


class DatabaseInstance(BaseModel):
    #id es connectionName
    name: str
    project: str
    region: str
    state: str
    #sku (en settings, tier)
    currentDiskSize: str
    maxDiskSize: str
    databaseVersion: str

'''
parámetros a obtener
id, name, location (region), db_sku, max_disk_size, resource_status, databaseVersion'''


class SQLDatabaseList(BaseModel):
    items: list[DatabaseInstance] = []

    @model_validator(mode="before")
    @classmethod
    def get_database_instances(cls, instances_data: dict):
        instances = []
        for instance in instances_data.get("items", []):
            instances.append(instance)
        return {"items": instances}
    

class BillingReport(BaseModel):
    id : str | None = None


class GCPResponse(BaseModel):
    count: int
    items: list[Union[ComputeInstance, BillingReport]]