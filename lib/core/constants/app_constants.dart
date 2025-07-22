class AppConstants {
  // App Info
  static const String appName = 'تطبيق النقل المدرسي';
  static const String appVersion = '1.0.0';

  // API URLs
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/v1';

  // Routes
  static const String homeRoute = '/home';
  static const String childrenRoute = '/children';
  static const String billsRoute = '/bills';
  static const String complaintsRoute = '/complaints';
  static const String newComplaintRoute = '/new-complaint';
  static const String ratingsRoute = '/ratings';
  static const String profileRoute = '/profile';
  static const String onboardingRoute = '/onboarding';

  // Shared Preferences Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'language';

  // Default Values
  static const String defaultLanguage = 'ar';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
}
