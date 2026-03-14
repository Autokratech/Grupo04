from fastapi import FastAPI
from api.routes.oauth import router as oauth_router

app = FastAPI(title="Autokratech", version="0.1.0")

# Endpoint raíz
@app.get("/", summary="Home")
async def root():
    #TODO: Implementar lógica para solicitar autenticación, si el user ya está autenticado redirige a dashboard
    return {"message": "Bienvenido a la API de Autokratech! ~ Grupo 04 LaSalle FP Online"}


#Rutas para integración con servicios de terceros
app.include_router(oauth_router)


