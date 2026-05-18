class AppConfig {
  const AppConfig({
    required this.useBackend,
    required this.apiBaseUrl,
  });

  final bool useBackend;
  final String apiBaseUrl;

  static const current = AppConfig(
    useBackend: bool.fromEnvironment('USE_BACKEND'),
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8787',
    ),
  );

  static const geminiModel = String.fromEnvironment(
    'GEMINI_MODEL_LABEL',
    defaultValue: 'Gemini 3 Pro Preview',
  );
}
