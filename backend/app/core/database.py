from supabase import create_client
from dotenv import load_dotenv
import os

load_dotenv()

def create_supabase_client():
    supabase_url = os.getenv("SUPABASE_URL")
    supabase_key = os.getenv("SUPABASE_KEY")

    if not supabase_url or not supabase_key: raise ValueError("No se han encontrado las credenciales para establecer la conexión con Supabase.")
    
    try:
      supabase_client = create_client(supabase_url, supabase_key)
      return supabase_client
    except Exception as e:
      raise ValueError(f"No se ha podido establecer la conexión: {e}")



FAKE_USERS = []
USER_ID_SEQ = 1


def next_user_id():
    global USER_ID_SEQ
    current = USER_ID_SEQ
    USER_ID_SEQ += 1
    return current
