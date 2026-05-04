import os
from dotenv import load_dotenv

load_dotenv()
# Variables y constantes para el acceso al la base de datos, clave jwt, etc.
SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "f2d8a5b1c9e3d7a4f5b6e2d1c0a9b8f7e6d5c4b3a2f1e0d9c8b7a6f5e4d3c2b1")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
JWT_EXPIRE_MINUTES = int(os.getenv("JWT_EXPIRE_MINUTES", "480"))
DEFAULT_ROLE_NAME_FOR_REGISTER = os.getenv("DEFAULT_ROLE_NAME_FOR_REGISTER", "SUPERADMIN")
SYSTEM_USER_ID = os.getenv("SYSTEM_USER_ID", "")
