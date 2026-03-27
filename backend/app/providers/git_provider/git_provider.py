
from .github_provider import GitHubProvider
from .gitlab_provider import GitlabProvider
from .bitbucket_provider import BitBucketProvider

class GitProvider():

    _git_provider_instance = {
        "github": GitHubProvider,
        "gitlab": GitlabProvider,
        "bitbucket": BitBucketProvider
    }

    async def get_provider_instance(self, provider_name : str, endpoints_repository):

        provider_instance = self._git_provider_instance[provider_name]
        if provider_instance is None:
            raise KeyError(f"No se ha encontrado el tipo de provider solicitado: {provider_name}.")
        return provider_instance(endpoints_repository)


    async def get_user_token(user_id : int, provider_name : str):
        pass