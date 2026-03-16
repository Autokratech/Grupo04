import os
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles

from app.routers import users_router

app = FastAPI(title="Autokratech", version="0.1.0")

base_path = os.path.dirname(os.path.abspath(__file__))
static_path = os.path.join(base_path, "statics")

app.mount("/static", StaticFiles(directory=static_path), name="static")
app.include_router(users_router.router, prefix="/api")


@app.get("/", response_class=HTMLResponse)
async def root():
    return """
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Autokratech</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
                background: #f0f2f5;
            }
            .logo-container { margin-bottom: 20px; }
            .logo { max-width: 140px; height: auto; }
            .card {
                background: white;
                padding: 2.5rem;
                border-radius: 16px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.05);
                text-align: center;
                width: 380px;
                border: 1px solid #e1e4e8;
            }
            h1 { color: #1a73e8; margin-top: 0; font-size: 1.8rem; }
            p { color: #5f6368; line-height: 1.5; }
            .btn {
                display: inline-block;
                margin-top: 20px;
                padding: 12px 24px;
                background-color: #1a73e8;
                color: white;
                text-decoration: none;
                border-radius: 8px;
                font-weight: 600;
                transition: background 0.3s ease;
            }
            .btn:hover { background-color: #1557b0; }
        </style>
    </head>
    <body>
        <div class="card">
            <div class="logo-container">
                <img src="/static/logo.png" alt="Logo Autokratech" class="logo">
            </div>
            <h1>API funcionando</h1>
            <p>La API de <strong>Autokratech</strong> está lista y funcionando correctamente.</p>
            <a href="/docs" class="btn">Ir a la Documentación</a>
        </div>
    </body>
    </html>
    """


@app.get("/dashboard", summary="Dashboard")
async def dashboard():
    return {"message": "Bienvenido al Dashboard de Autokratech!"}
