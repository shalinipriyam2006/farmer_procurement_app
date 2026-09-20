import 'package:flutter/foundation.dart';

enum AppEnvironment { development, production }

class AppConfig {
  // Compile-time environment override (--dart-define=ENVIRONMENT=production)
  static const String _envName = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Compile-time API URL override (--dart-define=API_BASE_URL=https://farmer-procurement-app-i0g6.onrender.com/api/v1)
  static const String _definedApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  // Development API Defaults
  static const String devLocalhostUrl = 'http://localhost:3000/api/v1';
  static const String devAndroidEmulatorUrl = 'http://10.0.2.2:3000/api/v1';

  // Live Production Render API Base URL
  static const String prodApiBaseUrl = 'https://farmer-procurement-app-i0g6.onrender.com/api/v1';

  // Configurable Procurement Helpdesk Toll-Free Number
  static const String helpLineNumber = '1800-425-4673';

  static AppEnvironment get environment {
    if (_envName.toLowerCase() == 'production' || kReleaseMode) {
      return AppEnvironment.production;
    }
    return AppEnvironment.development;
  }

  static bool get isProduction => environment == AppEnvironment.production;

  static String get apiBaseUrl {
    // 1. Prioritize explicit compile-time URL provided via --dart-define=API_BASE_URL=...
    if (_definedApiBaseUrl.isNotEmpty) {
      return _definedApiBaseUrl;
    }

    // 2. Production mode default (or release APK build default)
    if (isProduction) {
      return prodApiBaseUrl;
    }

    // 3. Local development fallback based on platform target
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return devAndroidEmulatorUrl;
    }

    return devLocalhostUrl;
  }

  /// Safe environment summary for debugging & configuration display (No secrets exposed)
  static Map<String, String> get activeEnvironmentSummary {
    return {
      'environment': environment.name.toUpperCase(),
      'apiBaseUrl': apiBaseUrl,
      'isReleaseMode': kReleaseMode.toString(),
      'targetPlatform': defaultTargetPlatform.name,
    };
  }
}
