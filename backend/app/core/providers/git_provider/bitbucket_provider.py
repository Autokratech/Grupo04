from fastapi import HTTPException
import httpx

class BitBucketProvider():
    
    PROVIDER_API_HOST="https://api.bitbucket.org"
    PROVIDER_TABLE_NAME="bitbucket_endpoints"