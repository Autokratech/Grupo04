from fastapi import FastAPI

app = FastAPI(title="Autokratech", version="0.1.0")

# Endpoint raíz
@app.get("/", summary="Home")
async def root():
    #TODO: Implementar lógica para solicitar autenticación, si el user ya está autenticado redirige a dashboard
    return {"message": "Bienvenido a la API de Autokratech!"}

@app.get("/dashboard", summary="Dashboard")
async def root():
    #TODO: Obtiene la config del usuario, qué widgets tiene activos, y en función de ello hace las llamadas pertienntes para cada uno
    return {"message": "Bienvenido al Dashboard de Autokratech!"}

