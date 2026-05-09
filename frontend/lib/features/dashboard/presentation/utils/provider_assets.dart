class ProviderAssets {
  static const String _basePath = 'assets/icons/providers';

  static String fromProvider(String? provider) {
    switch (provider?.toLowerCase().trim()) {
      case 'azure':
        return '$_basePath/azure.svg';

      case 'gcp':
      case 'google_cloud':
      case 'google-cloud':
      case 'google cloud':
        return '$_basePath/gcp.svg';

      case 'github':
        return '$_basePath/github.svg';

      case 'gitlab':
        return '$_basePath/gitlab.svg';

      case 'linux':
        return '$_basePath/linux.svg';

      case 'windows':
        return '$_basePath/windows.svg';

      default:
        return '$_basePath/generic.svg';
    }
  }
}