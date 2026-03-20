from fastapi import Request, Response
from fastapi.responses import RedirectResponse
from services.oauth_manager import OAuthManager


# -- Controladores para gestionar las conexiones OAuth
async def oauth_login(provider: str, response: Response):
    _, auth_url, state = OAuthManager.get_oauth_session(provider)
    response.set_cookie(key="state", value=state, httponly=True)
    return RedirectResponse(auth_url)


async def oauth_callback(provider: str, request: Request):
    state = request.cookies.get("state")
    token = OAuthManager.get_oauth_token(provider, str(request.url), state)
    return {"token" : token}
