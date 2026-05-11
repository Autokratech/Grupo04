from pydantic import BaseModel, model_validator, Field, field_validator
from typing import List, Union, Annotated, Literal

# -- Responses

#AZURE devuelve todo en formato
'''
"value" : [{<item>},{<item>}, ... ]
'''
#TODO: Revisar si hay una forma mejor de hacer esto
class SubscriptionID(BaseModel):
    id : str | None = None

    #Extraer el subscription_id de value
    @model_validator(mode="before")
    def get_subscription_id(cls, subscription_response):
        value_field = subscription_response.get("value", [])
        if value_field:
            return {"id" : value_field[0].get("subscriptionId")}
        return subscription_response


class ResourceGroup(BaseModel):
    type: Literal["Microsoft.Resources/resourceGroups"] = Field(default="Microsoft.Resources/resourceGroups", exclude=True)
    id : str
    name : str
    location : str
    tags : dict | None = None 


class VirtualMachine(BaseModel):
    type: Literal["Microsoft.Compute/virtualMachines"] = Field(default="Microsoft.Compute/virtualMachines", exclude=True)
    id : str
    name : str
    location : str
    vm_sku : str
    disk_size : int | None = None #revisar si esto se obtiene
    os_type: str
    os_distro : str
    os_version: str
    power_state : str | None = None #Nota: pendiente de obtener, hay que hacer una segunda llamada

    @model_validator(mode="before")
    @classmethod
    def get_vm_data(cls, vm_data):
        properties = vm_data.get("properties", {})
        vm_data["vm_sku"] = properties.get("hardwareProfile", {}).get("vmSize")
        vm_data["disk_size"] = properties.get("storageProfile", {}).get("osDisk", {}).get("diskSizeGB")
        vm_data["os_type"] = properties.get("storageProfile", {}).get("osDisk", {}).get("osType")
        vm_data["os_distro"] = properties.get("storageProfile", {}).get("imageReference", {}).get("offer")
        vm_data["os_version"] = properties.get("storageProfile", {}).get("imageReference", {}).get("exactVersion")
        return vm_data

class VirtualMachineStatus(BaseModel):
    code: str
    displayStatus: str | None = None

class VirtualMachineInstanceView(BaseModel):
  statuses: list[VirtualMachineStatus] = []

  def get_power_state(self):
    for status in self.statuses:
        if status.code.startswith("PowerState/"):
            power_state = status.code.removeprefix("PowerState/")
            return "on" if power_state.lower() == "running" else "off"

class KeyVault(BaseModel):
    type: Literal["Microsoft.KeyVault/vaults"] = Field(default="Microsoft.KeyVault/vaults", exclude=True)
    id : str
    name : str
    location : str
    tags : dict | None = None

class ResourceCost(BaseModel):
    resource: str
    cost: float
    currency: str

class CostManagement(BaseModel):
    type: Literal["Microsoft.CostManagement/query"] = Field(default="Microsoft.CostManagement/query", exclude=True)
    id: str
    total_cost: float = 0.0
    currency: str = ""
    resource_cost: list[ResourceCost] = []

    @model_validator(mode="before")
    @classmethod
    def get_cost_by_resource(cls, cost_data: dict):
      properties_rows = cost_data.get("properties", {}).get("rows", [])
      cost_data["resource_cost"] = []
      cost_data["total_cost"] = 0.0
      cost_data["currency"] = ""

      for price, resource, currency in properties_rows:
          cost_data["resource_cost"].append(ResourceCost(cost=price, resource=resource, currency=currency))
          cost_data["total_cost"] += price
          if not cost_data["currency"]: cost_data["currency"] = currency
      
      return cost_data



class AzureResponse(BaseModel):
    count: int
    items: list[Annotated[Union[ResourceGroup, VirtualMachine, KeyVault, CostManagement], Field(discriminator="type")]]

#TODO: Mejorar esto con https://pydantic.dev/docs/validation/latest/concepts/unions#discriminated-unions

#https://stackoverflow.com/questions/25833613/safe-method-to-get-value-of-nested-dictionary