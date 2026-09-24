class AppSettings {
  final String apiKey;
  final String provider; // 'gemini' or 'openai'
  final String baseUrl;
  final String modelName;
  final bool enableMockSimulation;

  const AppSettings({
    this.apiKey = '',
    this.provider = 'gemini',
    this.baseUrl = 'https://generativelanguage.googleapis.com',
    this.modelName = 'gemini-1.5-flash',
    this.enableMockSimulation = true,
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
    return AppSettings(
      apiKey: map['api_key'] as String? ?? '',
      provider: map['provider'] as String? ?? 'gemini',
      baseUrl: map['base_url'] as String? ?? 'https://generativelanguage.googleapis.com',
      modelName: map['model_name'] as String? ?? 'gemini-1.5-flash',
      enableMockSimulation: map['enable_mock_simulation'] as bool? ?? true,
    );
  }
}
