from abc import ABC, abstractmethod

class IKMSClient(ABC):
    
    @abstractmethod
    async def get_crypto_client(self, key_name : str):
        pass


    @abstractmethod
    async def wrap_key(self, dek : bytes, kek_name : str):
        pass


    @abstractmethod
    async def unwrap_key(self, wrapped_dek : bytes, kek_name : str): 
        pass
 
 