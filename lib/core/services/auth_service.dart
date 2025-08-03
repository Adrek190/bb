import 'package:supabase_flutter/supabase_flutter.dart';

/// خدمة المصادقة مع Supabase Auth
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// المستخدم الحالي
  User? get currentUser => _supabase.auth.currentUser;

  /// التحقق من حالة تسجيل الدخول
  bool get isSignedIn => currentUser != null;

  /// تدفق تغييرات حالة المصادقة
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// تسجيل مستخدم جديد
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  /// الحصول على معرف المستخدم الحالي
  String? get currentUserId => currentUser?.id;

  /// الحصول على بريد المستخدم الحالي
  String? get currentUserEmail => currentUser?.email;

  /// التحقق من تأكيد البريد الإلكتروني
  bool get isEmailConfirmed => currentUser?.emailConfirmedAt != null;

  /// الحصول على معرف الوالد من جدول parents
  Future<String?> getParentId() async {
    try {
      if (currentUserId == null) {
        print('❌ لا يوجد مستخدم متصل');
        return null;
      }

      print('🔍 البحث عن معرف الوالد للمستخدم: $currentUserId');

      final response = await _supabase
          .from('parents')
          .select('parent_id')
          .eq('auth_id', currentUserId!)
          .maybeSingle();

      if (response == null) {
        print('❌ لم يتم العثور على الوالد في جدول parents');
        return null;
      }

      final parentId = response['parent_id'] as String?;
      print('✅ تم العثور على معرف الوالد: $parentId');

      return parentId;
    } catch (e) {
      print('❌ خطأ في جلب معرف الوالد: $e');
      return null;
    }
  }
}
