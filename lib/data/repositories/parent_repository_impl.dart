import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/parent_entity.dart';
import '../../domain/repositories/parent_repository.dart';

/// Supabase implementation of ParentRepository
///
/// This class handles all parent-related operations using Supabase as backend
/// It manages profile data, image uploads, and authentication integration
class ParentRepositoryImpl implements ParentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<ParentEntity> getCurrentParent() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const ParentException('المستخدم غير مسجل دخول');
      }

      return await getParentByAuthId(user.id);
    } catch (e) {
      if (e is ParentException) rethrow;
      throw ParentException('فشل في جلب بيانات الوالد', originalError: e);
    }
  }

  @override
  Future<ParentEntity> getParentByAuthId(String authId) async {
    try {
      final response = await _supabase
          .from('parents')
          .select('*')
          .eq('auth_id', authId)
          .eq('is_active', true)
          .single();

      return ParentEntity.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const ParentNotFoundException('لم يتم العثور على بيانات الوالد');
      }
      throw ParentException(
        'خطأ في قاعدة البيانات: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw ParentException('فشل في جلب بيانات الوالد', originalError: e);
    }
  }

  @override
  Future<ParentEntity> updateParent(ParentEntity parent) async {
    try {
      final updateData = {
        'parent_name': parent.parentName,
        'phone': parent.phone,
        'email': parent.email,
        'profile_image_url': parent.profileImageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('parents')
          .update(updateData)
          .eq('parent_id', parent.parentId)
          .eq('is_active', true)
          .select('*')
          .single();

      return ParentEntity.fromJson(response);
    } on PostgrestException catch (e) {
      throw ParentException(
        'فشل في تحديث بيانات الوالد: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw ParentException('فشل في تحديث بيانات الوالد', originalError: e);
    }
  }

  @override
  Future<ParentEntity> updateParentName(String parentId, String newName) async {
    try {
      if (newName.trim().isEmpty) {
        throw const ParentException('اسم الوالد لا يمكن أن يكون فارغاً');
      }

      final response = await _supabase
          .from('parents')
          .update({
            'parent_name': newName.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('parent_id', parentId)
          .eq('is_active', true)
          .select('*')
          .single();

      return ParentEntity.fromJson(response);
    } on PostgrestException catch (e) {
      throw ParentException(
        'فشل في تحديث الاسم: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is ParentException) rethrow;
      throw ParentException('فشل في تحديث الاسم', originalError: e);
    }
  }

  @override
  Future<ParentEntity> updateParentEmail(
    String parentId,
    String newEmail,
  ) async {
    try {
      // التحقق من صحة البريد الإلكتروني
      if (newEmail.isNotEmpty && !_isValidEmail(newEmail)) {
        throw const ParentException('عنوان البريد الإلكتروني غير صحيح');
      }

      final response = await _supabase
          .from('parents')
          .update({
            'email': newEmail.trim().isEmpty ? null : newEmail.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('parent_id', parentId)
          .eq('is_active', true)
          .select('*')
          .single();

      return ParentEntity.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const ParentException(
          'هذا البريد الإلكتروني مستخدم من قبل مستخدم آخر',
        );
      }
      throw ParentException(
        'فشل في تحديث البريد الإلكتروني: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is ParentException) rethrow;
      throw ParentException('فشل في تحديث البريد الإلكتروني', originalError: e);
    }
  }

  @override
  Future<ParentEntity> updateParentPhone(
    String parentId,
    String newPhone,
  ) async {
    try {
      if (newPhone.trim().isEmpty) {
        throw const ParentException('رقم الهاتف لا يمكن أن يكون فارغاً');
      }

      // التحقق من صحة رقم الهاتف
      if (!_isValidPhone(newPhone)) {
        throw const ParentException('رقم الهاتف غير صحيح');
      }

      final response = await _supabase
          .from('parents')
          .update({
            'phone': newPhone.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('parent_id', parentId)
          .eq('is_active', true)
          .select('*')
          .single();

      return ParentEntity.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const ParentException('هذا الرقم مستخدم من قبل مستخدم آخر');
      }
      throw ParentException(
        'فشل في تحديث رقم الهاتف: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is ParentException) rethrow;
      throw ParentException('فشل في تحديث رقم الهاتف', originalError: e);
    }
  }

  @override
  Future<ParentEntity> updateParentProfileImage(
    String parentId,
    String imageUrl,
  ) async {
    try {
      final response = await _supabase
          .from('parents')
          .update({
            'profile_image_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('parent_id', parentId)
          .eq('is_active', true)
          .select('*')
          .single();

      return ParentEntity.fromJson(response);
    } on PostgrestException catch (e) {
      throw ParentException(
        'فشل في تحديث الصورة الشخصية: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw ParentException('فشل في تحديث الصورة الشخصية', originalError: e);
    }
  }

  @override
  Future<String> uploadProfileImage(String parentId, String imagePath) async {
    try {
      // إنشاء اسم فريد للملف
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_$parentId$timestamp.jpg';
      final filePath = 'profiles/$fileName';

      // رفع الصورة إلى Supabase Storage
      await _supabase.storage
          .from('parent-profiles')
          .upload(filePath, File(imagePath));

      // الحصول على الرابط العام للصورة
      final imageUrl = _supabase.storage
          .from('parent-profiles')
          .getPublicUrl(filePath);

      return imageUrl;
    } on StorageException catch (e) {
      throw ParentException(
        'فشل في رفع الصورة: ${e.message}',
        code: e.error,
        originalError: e,
      );
    } catch (e) {
      throw ParentException('فشل في رفع الصورة', originalError: e);
    }
  }

  @override
  Future<ParentEntity> updateLastLogin(String parentId) async {
    try {
      final response = await _supabase
          .from('parents')
          .update({
            'last_login': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('parent_id', parentId)
          .eq('is_active', true)
          .select('*')
          .single();

      return ParentEntity.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint('خطأ في تحديث آخر دخول: ${e.message}');
      throw ParentException(
        'فشل في تحديث آخر دخول: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      debugPrint('خطأ في تحديث آخر دخول: $e');
      throw ParentException('فشل في تحديث آخر دخول', originalError: e);
    }
  }

  /// التحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// التحقق من صحة رقم الهاتف (السعودية)
  bool _isValidPhone(String phone) {
    // أرقام الهاتف السعودية: 05xxxxxxxx أو +966xxxxxxxxx
    final saudiPhoneRegex = RegExp(r'^(05|5)\d{8}$|^\+9665\d{8}$');
    return saudiPhoneRegex.hasMatch(
      phone.replaceAll(' ', '').replaceAll('-', ''),
    );
  }
}
