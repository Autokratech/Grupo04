from fastapi import Request
from fastapi.responses import JSONResponse
from app.core.exceptions import *

def init_exception_handlers(app):
    @app.exception_handler(DatabaseError)
    async def database_error_handler(request: Request, exc: DatabaseError):
        return JSONResponse(
            status_code=500,
            content={"detail": str(exc)}
        )

    @app.exception_handler(BadRequestError)
    async def bad_request_error_handler(request: Request, exc: BadRequestError):
        return JSONResponse(
            status_code=400,
            content={"detail": str(exc)}
        )

    @app.exception_handler(InvalidValueError)
    async def value_error_handler(request: Request, exc: InvalidValueError):
        return JSONResponse(
            status_code=400,
            content={"detail": str(exc)}
        )

#--> https://www.reddit.com/r/FastAPI/comments/1g06ffz/what_is_the_best_way_to_structure_exception/