// ==========================================
// إعدادات Supabase
// نظام النقل المدرسي
// ==========================================

class SupabaseConfig {
  // معلومات الاتصال بقاعدة البيانات
  static const String supabaseUrl = 'https://lxbfizpllcnfqudlqhah.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4YmZpenBsbGNuZnF1ZGxxaGFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI5NjM1ODAsImV4cCI6MjA2ODUzOTU4MH0.ZQY9DUCIAM7vDAzxEhbxLrDjDNpHijIWvSjzYycrqnc';

  // Storage buckets
  static const String profileImagesBucket = 'profile-images';
  static const String documentsBucket = 'documents';

  // أسماء الجداول
  static const String citiesTable = 'cities';
  static const String districtsTable = 'districts';
  static const String schoolsTable = 'schools';
  static const String parentsTable = 'parents';
  static const String childrenTable = 'children';
  static const String addChildRequestsTable = 'add_child_requests';

  // إعدادات Real-time Channels
  static const String requestsChannel = 'add_child_requests_channel';
  static const String notificationsChannel = 'notifications_channel';
  static const String tripsChannel = 'trips_channel';

  // إعدادات Cache
  static const Duration cacheMaxAge = Duration(minutes: 15);
  static const Duration cacheMaxStale = Duration(hours: 1);

  // إعدادات Retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
