from supabase import create_client
from dotenv import load_dotenv
import os

load_dotenv()


def _crear_cliente_sync():
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    return create_client(url, key)


supabase = _crear_cliente_sync()
