import os
from fastapi import FastAPI
from app.api.routers import *
from fastapi.responses import HTMLResponse

from app.middlewares.jwt_auth_middleware import MiddlewareJwt
from app.routers import auth_router, permissions_router, roles_router, users_router, metrics_router
from fastapi.staticfiles import StaticFiles

app = FastAPI(
    title="Api",
    version="1.0.0",
    description="Autokratech, FastAPI, Supabase y JWT",
)

base_path = os.path.dirname(os.path.abspath(__file__))
static_path = os.path.join(base_path, "statics")

app.mount("/static", StaticFiles(directory=static_path), name="static")

app.add_middleware(MiddlewareJwt)

app.include_router(auth_router.router, prefix="/api")
app.include_router(users_router.router, prefix="/api")
app.include_router(roles_router.router, prefix="/api")
app.include_router(permissions_router.router, prefix="/api")
app.include_router(metrics_router.router, prefix="/api")

# Rutas para la administración del dashboard
app.include_router(dashboard_router)

# Rutas para la administración de las pestañas
app.include_router(tabs_router)

# Rutas para la administración de los widgets 
app.include_router(widgets_router)

# Rutas para la integración con servicios de terceros
app.include_router(oauth_router)

# Rutas para la integración del orquestador
app.include_router(orchestrator_router)


@app.get("/", summary="Home", response_class=HTMLResponse)
async def root():
    return """
    <!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Autokratech | API Status</title>
    <style>
        :root {
            --primary: #2563eb;
            --primary-hover: #1d4ed8;
            --bg: #f8fafc;
            --text-main: #1e293b;
            --text-muted: #64748b;
        }

        body { 
            font-family: 'Inter', 'Segoe UI', system-ui, sans-serif; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
            margin: 0; 
            background-color: var(--bg);
            background-image: radial-gradient(circle at top right, #e2e8f0 0%, transparent 25%);
        }

        .card { 
            background: white; 
            padding: 3rem 2rem; 
            border-radius: 24px; 
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            text-align: center; 
            width: 100%;
            max-width: 400px;
            border: 1px solid rgba(226, 232, 240, 0.8);
        }

        .logo-container { margin-bottom: 1.5rem; }
        
        .logo { 
            max-width: 120px; 
            height: auto; 
            filter: drop-shadow(0 4px 6px rgba(0,0,0,0.05));
        }

        h1 { 
            color: var(--text-main); 
            font-size: 1.5rem; 
            margin-bottom: 0.5rem;
            letter-spacing: -0.025em;
        }

        p { 
            color: var(--text-muted); 
            line-height: 1.6;
            margin-bottom: 2rem;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            background: #dcfce7;
            color: #166534;
            padding: 0.25rem 0.75rem;
            border-radius: 99px;
            font-size: 0.875rem;
            font-weight: 500;
            margin-bottom: 1rem;
        }

        .status-dot {
            height: 8px;
            width: 8px;
            background-color: #22c55e;
            border-radius: 50%;
            display: inline-block;
            margin-right: 6px;
            animation: pulse 2s infinite;
        }

        .btn {
            display: inline-block;
            background-color: var(--primary);
            color: white;
            padding: 0.8rem 1.5rem;
            text-decoration: none;
            border-radius: 12px;
            font-weight: 600;
            transition: all 0.2s ease;
            box-shadow: 0 4px 6px -1px rgba(37, 99, 235, 0.2);
        }

        .btn:hover {
            background-color: var(--primary-hover);
            transform: translateY(-1px);
            box-shadow: 0 10px 15px -3px rgba(37, 99, 235, 0.3);
        }

        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="logo-container">
            <!-- Asegúrate de que la ruta sea correcta -->
            <img src="/static/logo.png" alt="Autokratech" class="logo">
        </div>
        
        <div class="status-badge">
            <span class="status-dot"></span> Online
        </div>

        <h1>API Funcionando</h1>
        <p>Los servicios de <strong>Autokratech</strong> están operativos. Puedes consultar la documentación técnica aquí debajo.</p>
        
        <a href="/docs" class="btn">Explorar Documentación</a>
    </div>
</body>
</html>
    """
