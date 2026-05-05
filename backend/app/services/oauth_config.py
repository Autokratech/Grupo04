
import os
from dotenv import load_dotenv

load_dotenv()

oauth_config = {
    "gitlab" : {
        "auth_url" : os.getenv("GITLAB_OAUTH_AUTHORIZE_URL"),
        "token_url" : os.getenv("GITLAB_OAUTH_TOKEN_URL"),
        "client_id" : os.getenv("GITLAB_OAUTH_CLIENT_ID"),
        "client_secret" : os.getenv("GITLAB_OAUTH_CLIENT_SECRET"),
        "redirect_url" : os.getenv("GITLAB_OAUTH_REDIRECT_URL"),
        "refresh_url" : os.getenv("GITLAB_OAUTH_REFRESH_URL"),
        "scopes" : os.getenv("GITLAB_OAUTH_SCOPES")
    },

    "github" : {
        "auth_url" : os.getenv("GITHUB_OAUTH_AUTHORIZE_URL"),
        "token_url" : os.getenv("GITHUB_OAUTH_TOKEN_URL"),
        "client_id" : os.getenv("GITHUB_OAUTH_CLIENT_ID"),
        "client_secret" : os.getenv("GITHUB_OAUTH_CLIENT_SECRET"),
        "redirect_url" : os.getenv("GITHUB_OAUTH_REDIRECT_URL"),
        "scopes" : os.getenv("GITHUB_OAUTH_SCOPES") 
    },

    "bitbucket" : {
        "auth_url" : os.getenv("BITBUCKET_OAUTH_AUTHORIZE_URL"),
        "token_url" : os.getenv("BITBUCKET_OAUTH_TOKEN_URL"),
        "client_id" : os.getenv("BITBUCKET_OAUTH_CLIENT_ID"),
        "client_secret" : os.getenv("BITBUCKET_OAUTH_CLIENT_SECRET"),
        "redirect_url" : os.getenv("BITBUCKET_OAUTH_REDIRECT_URL"),
        "scopes" : os.getenv("BITBUCKET_OAUTH_SCOPES") 
    },

    "gcp" : {
        "auth_url" : os.getenv("GCP_OAUTH_AUTHORIZE_URL"),
        "token_url" : os.getenv("GCP_OAUTH_TOKEN_URL"),
        "client_id" : os.getenv("GCP_OAUTH_CLIENT_ID"),
        "client_secret" : os.getenv("GCP_OAUTH_CLIENT_SECRET"),
        "redirect_url" : os.getenv("GCP_OAUTH_REDIRECT_URL"),
        "refresh_url" : os.getenv("GCP_OAUTH_REFRESH_URL"),
        "scopes" : os.getenv("GCP_OAUTH_SCOPES"),
        "extra_params": {       
            "access_type": "offline"
        },
    },

    "azure" : {
        "auth_url" : os.getenv("AZURE_OAUTH_AUTHORIZE_URL"),
        "token_url" : os.getenv("AZURE_OAUTH_TOKEN_URL"),
        "client_id" : os.getenv("AZURE_OAUTH_CLIENT_ID"),
        "client_secret" : os.getenv("AZURE_OAUTH_CLIENT_SECRET"),
        "redirect_url" : os.getenv("AZURE_OAUTH_REDIRECT_URL"),
        "refresh_url" : os.getenv("AZURE_OAUTH_REFRESH_URL"),
        "scopes" : os.getenv("AZURE_OAUTH_SCOPES") 
    },

    "aws" : {
        "auth_url" : os.getenv("AWS_OAUTH_AUTHORIZE_URL"),
        "token_url" : os.getenv("AWS_OAUTH_TOKEN_URL"),
        "client_id" : os.getenv("AWS_OAUTH_CLIENT_ID"),
        "client_secret" : os.getenv("AWS_OAUTH_CLIENT_SECRET"),
        "redirect_url" : os.getenv("AWS_OAUTH_REDIRECT_URL"),
        "refresh_url" : os.getenv("AWS_OAUTH_REFRESH_URL"),
        "scopes" : os.getenv("AWS_OAUTH_SCOPES") 
    }
}
