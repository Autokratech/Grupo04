from fastapi import HTTPException
import httpx

class GitlabProvider():
    
    PROVIDER_API_HOST="https://gitlab.com"
    PROVIDER_TABLE_NAME="gitlab_endpoints"
