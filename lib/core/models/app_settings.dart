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
    this.modelName = 'gemini-3.5-flash',
    this.enableMockSimulation = false,
  });

  /// True if user explicitly entered a personal key in Settings UI
  bool get hasCustomApiKey => apiKey.trim().isNotEmpty;

  /// In the secure serverless architecture:
  /// - Real AI is available via Vercel /api/gemini backend proxy by default
  /// - Or via custom direct key if provided
  /// - Available unless user explicitly turns ON mock simulation
  bool get isRealAiAvailable => !enableMockSimulation;

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
    final rawModel = map['model_name'] as String? ?? 'gemini-3.5-flash';
    final isLegacy = rawModel.contains('1.5') || rawModel.contains('2.0') || rawModel.contains('2.5');
    final normalizedModel = isLegacy ? 'gemini-3.5-flash' : rawModel;

    return AppSettings(
      apiKey: map['api_key'] as String? ?? '',
      provider: map['provider'] as String? ?? 'gemini',
      baseUrl: map['base_url'] as String? ?? 'https://generativelanguage.googleapis.com',
      modelName: normalizedModel,
      enableMockSimulation: map['enable_mock_simulation'] as bool? ?? false,
    );
  }
}
