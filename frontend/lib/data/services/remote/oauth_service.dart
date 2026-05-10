import 'package:frontend/data/services/remote/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class OAuthService {
  final ApiClient apiClient;

  const OAuthService({required this.apiClient});

  Future<void> connectGithub() {
    return connectProvider('github');
  }

  Future<void> connectProvider(String provider) async {
    final normalizedProvider = provider.trim().toLowerCase();

    if (normalizedProvider.isEmpty) {
      throw StateError('Provider OAuth no válido');
    }

    final authorizationUrl = await apiClient.getRedirectLocation(
      _providerOAuthEndpoint(normalizedProvider),
    );

    final launched = await launchUrl(
      authorizationUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('No se ha podido abrir OAuth para $normalizedProvider');
    }
  }

  String _providerOAuthEndpoint(String provider) {
    final encodedProvider = Uri.encodeComponent(provider);
    return '/api/oauth/$encodedProvider';
  }
}
