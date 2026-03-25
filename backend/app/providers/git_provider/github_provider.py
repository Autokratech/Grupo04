from fastapi import HTTPException
import httpx

class GitHubProvider():
    
    PROVIDER_API_HOST="https://api.github.com"
    PROVIDER_TABLE_NAME="github_endpoints"
