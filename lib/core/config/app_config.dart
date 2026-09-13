import 'package:flutter/foundation.dart';

enum AppEnvironment { development, production }

class AppConfig {
  // Compile-time environment override (--dart-define=ENVIRONMENT=production)
  static const String _envName = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Compile-time API URL override (--dart-define=API_BASE_URL=https://your-domain.com/api/v1)
  static const String _definedApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  // Development API Defaults
  static const String devLocalhostUrl = 'http://localhost:3000/api/v1';
  static const String devAndroidEmulatorUrl = 'http://10.0.2.2:3000/api/v1';

  // Production API Base URL Placeholder (Do NOT change unless backend is deployed with HTTPS)
  static const String prodApiBaseUrlPlaceholder = 'https://api.procurement.gov.in/v1';

  static AppEnvironment get environment {
    return _envName.toLowerCase() == 'production'
        ? AppEnvironment.production
        : AppEnvironment.development;
  }

  static bool get isProduction => environment == AppEnvironment.production;

  static String get apiBaseUrl {
    // 1. If explicit compile-time URL provided via --dart-define, prioritize it
    if (_definedApiBaseUrl.isNotEmpty) {
      return _definedApiBaseUrl;
    }

    // 2. Production mode default
    if (isProduction) {
      return prodApiBaseUrlPlaceholder;
    }

    // 3. Development mode default based on platform target
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 is Android emulator host loopback.
      // For real Android device on local Wi-Fi, pass --dart-define=API_BASE_URL=http://<YOUR_LAN_IP>:3000/api/v1
      return devAndroidEmulatorUrl;
    }

    return devLocalhostUrl;
  }
}
