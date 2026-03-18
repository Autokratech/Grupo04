import redis.asyncio as redis
from fastapi import HTTPException
from dotenv import load_dotenv
import os

#TODO: Decidir si la bbdd y el caché se gestionarán con pools de conexiones o inyección de dependencias (o cada uno con una)
#De momento se queda como ID, FastAPI gestiona bien su ciclo de vida y es más ordenado

load_dotenv()

def create_redis_client():
    redis_url = os.getenv("REDIS_URL")
    redis_port = os.getenv("REDIS_PORT")
    redis_key = os.getenv("REDIS_ACCESS_KEY")

    if not redis_url or not redis_key: raise ValueError("No se han encontrado los parámetros necesarios para establecer la conexión con Redis.")
    
    try:
        redis_client = redis.REDIS(
        host=redis_url,
        port=redis_port,
        password=redis_key,
        ssl=True,
        )
        #Se verifica la conexión con el servidor de Redis (el ping devuelve un bool únicamente!)
        if not redis_client.ping():
            raise HTTPException(status_code=500, detail="Se ha producido un error al intentar establecer la conexión con Redis.")
        
        return redis_client

    except Exception as e:
      raise HTTPException(status_code=500, detail=f"No se ha podido establecer la conexión con Redis: {e}")


async def get_redis_client():
    redis_client = create_redis_client()
    return redis_client
