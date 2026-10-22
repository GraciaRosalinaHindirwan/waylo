class GeminiConfig {
  static const String apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  static const String baseUrl = 'https://generativelanguage.googleapis.com';

  static const String model = 'gemini-3.8-flash';
}