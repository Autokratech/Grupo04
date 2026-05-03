from supabase import acreate_client
from app.core.exceptions import DatabaseError
from dotenv import load_dotenv
import os

load_dotenv()


async def create_supabase_client():
    supabase_url = os.getenv("SUPABASE_URL")
    supabase_key = os.getenv("SUPABASE_KEY")

    if not supabase_url or not supabase_key:
        raise ValueError("No se han encontrado las credenciales para establecer la conexión con Supabase.")

    try:
        return await acreate_client(supabase_url, supabase_key)
    except Exception as e:
        raise DatabaseError(e)

