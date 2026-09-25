class AppSettings {
  final String apiKey;
  final String provider; // 'gemini' or 'openai'
  final String baseUrl;
  final String modelName;
  final bool enableMockSimulation;

  static const String envGeminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String envGeminiModel =
      String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-1.5-flash');
  static const String envGeminiBaseUrl =
      String.fromEnvironment('GEMINI_BASE_URL', defaultValue: 'https://generativelanguage.googleapis.com');

  const AppSettings({
    this.apiKey = envGeminiApiKey,
    this.provider = 'gemini',
    this.baseUrl = envGeminiBaseUrl,
    this.modelName = envGeminiModel,
    this.enableMockSimulation = envGeminiApiKey == '',
  });

  AppSettings copyWith({
    String? apiKey,
    String? provider,
    String? baseUrl,
    String? modelName,
    bool? enableMockSimulation,
  }) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
      provider: provider ?? this.provider,
      baseUrl: baseUrl ?? this.baseUrl,
      modelName: modelName ?? this.modelName,
      enableMockSimulation: enableMockSimulation ?? this.enableMockSimulation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'api_key': apiKey,
      'provider': provider,
      'base_url': baseUrl,
      'model_name': modelName,
      'enable_mock_simulation': enableMockSimulation,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    final storedKey = map['api_key'] as String? ?? '';
    final effectiveKey = storedKey.isNotEmpty ? storedKey : envGeminiApiKey;
    final bool hasEnvKeyOnly = storedKey.isEmpty && envGeminiApiKey.isNotEmpty;
    return AppSettings(
      apiKey: effectiveKey,
      provider: map['provider'] as String? ?? 'gemini',
      baseUrl: map['base_url'] as String? ?? envGeminiBaseUrl,
      modelName: map['model_name'] as String? ?? envGeminiModel,
      enableMockSimulation: hasEnvKeyOnly
          ? false
          : (map['enable_mock_simulation'] as bool? ?? effectiveKey.isEmpty),
    );
  }
}
