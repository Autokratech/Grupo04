class ProviderAssets {
  static const String _basePath = 'assets/icons/providers';

  static String fromProvider(String? provider) {
    switch (provider?.toLowerCase().trim()) {
      case 'azure':
      case 'microsoft':
      case 'microsoft_azure':
      case 'microsoft-azure':
      case 'microsoft azure':
        return '$_basePath/azure.svg';

      case 'gcp':
      case 'google':
      case 'google_cloud':
      case 'google-cloud':
      case 'google cloud':
        return '$_basePath/gcp.svg';

      case 'github':
      case 'git_hub':
      case 'git-hub':
      case 'git hub':
        return '$_basePath/github.svg';

      case 'gitlab':
      case 'git_lab':
      case 'git-lab':
      case 'git lab':
        return '$_basePath/gitlab.svg';

      case 'linux':
        return '$_basePath/linux.svg';

      case 'windows':
      case 'agent':
      case 'agents':
      case 'system':
      case 'system_data':
      case 'system-data':
      case 'system data':
        return '$_basePath/windows.svg';

      default:
        return '$_basePath/generic.svg';
    }
  }
}
