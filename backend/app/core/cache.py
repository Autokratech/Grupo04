import redis.asyncio as redis
from app.core.exceptions import CacheError
from dotenv import load_dotenv
import os


load_dotenv()

async def create_redis_client():
    redis_url = os.getenv("REDIS_URL")
    redis_port = os.getenv("REDIS_PORT")
    redis_key = os.getenv("REDIS_ACCESS_KEY")

    if not redis_url or not redis_key: raise ValueError("No se han encontrado los parámetros necesarios para establecer la conexión con Redis.")
    
    #TODO: Programar un par de retry automáticos antes de fallar
    try:
        redis_client = redis.Redis(
            host=redis_url,
            port=redis_port,
            password=redis_key,
            ssl=True,
            )
        
        redis_ping = await redis_client.ping()

        if not redis_ping:
            raise CacheError()

        return redis_client
  
    except Exception as e:
      raise CacheError(e)
