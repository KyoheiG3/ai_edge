import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _hfTokenKey = 'huggingface_token';
  static const String _tokenEnabledKey = 'token_enabled';

  /// Save HuggingFace API token
  Future<void> saveHuggingFaceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hfTokenKey, token);
  }

  /// Get HuggingFace API token
  Future<String?> getHuggingFaceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hfTokenKey);
  }

  /// Remove HuggingFace API token
  Future<void> removeHuggingFaceToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hfTokenKey);
  }

  /// Check if token authentication is enabled
  Future<bool> isTokenEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tokenEnabledKey) ?? false;
  }

  /// Set token authentication enabled state
  Future<void> setTokenEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tokenEnabledKey, enabled);
  }

  /// Check if token is configured
  Future<bool> hasToken() async {
    final token = await getHuggingFaceToken();
    return token != null && token.isNotEmpty;
  }

  /// Get authorization header if token is available and enabled
  Future<Map<String, String>?> getAuthorizationHeader() async {
    final isEnabled = await isTokenEnabled();
    if (!isEnabled) return null;

    final token = await getHuggingFaceToken();
    if (token == null || token.isEmpty) return null;

    return {
      'Authorization': 'Bearer $token',
    };
  }
}