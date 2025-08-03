// lib/data/repositories/children_repository_impl.dart
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/child.dart';
import '../../domain/repositories/children_repository.dart';
import '../models/child_model.dart';

/// Supabase implementation of ChildrenRepository
class ChildrenRepositoryImpl implements ChildrenRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<Child>> getApprovedChildren() async {
    try {
      // Get current authenticated user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        developer.log('لا يوجد مستخدم مسجل الدخول', name: 'ChildrenRepository');
        return [];
      }

      // Get parent_id from parents table using auth_id
      final parentResponse = await _supabase
          .from('parents')
          .select('parent_id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (parentResponse == null) {
        developer.log(
          'لم يتم العثور على بيانات الوالد',
          name: 'ChildrenRepository',
        );
        return [];
      }

      final parentId = parentResponse['parent_id'] as String;

      // Get approved children for this parent
      final response = await _supabase
          .from('children')
          .select('''
            *,
            districts(district_name),
            schools(school_name)
          ''')
          .eq('parent_id', parentId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final children = response.map<Child>((json) {
        final child = ChildModel.fromJson(json).toEntity();
        // Update child with relationship data
        return Child(
          id: child.id,
          name: child.name,
          gender: child.gender,
          location: child.location,
          currentLocation: child.currentLocation,
          educationLevel: child.educationLevel,
          profileImagePath: child.profileImagePath,
          city: '', // Could be fetched from districts->cities if needed
          district: json['districts']?['district_name'] ?? '',
          school: json['schools']?['school_name'] ?? '',
          entryTime: child.entryTime,
          exitTime: child.exitTime,
          studyDays: child.studyDays,
          tripTypes: child.tripTypes,
          subscriptionType: child.subscriptionType,
          createdAt: child.createdAt,
          isActive: child.isActive,
        );
      }).toList();

      developer.log(
        'تم جلب ${children.length} طفل/طفلة',
        name: 'ChildrenRepository',
      );
      return children;
    } catch (e) {
      developer.log(
        'خطأ في جلب الأطفال المقبولين: $e',
        name: 'ChildrenRepository',
      );
      return [];
    }
  }

  @override
  Future<Child?> getChildById(String childId) async {
    try {
      final response = await _supabase
          .from('children')
          .select('''
            *,
            districts(district_name),
            schools(school_name)
          ''')
          .eq('child_id', childId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;

      final child = ChildModel.fromJson(response).toEntity();
      // Update child with relationship data
      return Child(
        id: child.id,
        name: child.name,
        gender: child.gender,
        location: child.location,
        currentLocation: child.currentLocation,
        educationLevel: child.educationLevel,
        profileImagePath: child.profileImagePath,
        city: '', // Could be fetched from districts->cities if needed
        district: response['districts']?['district_name'] ?? '',
        school: response['schools']?['school_name'] ?? '',
        entryTime: child.entryTime,
        exitTime: child.exitTime,
        studyDays: child.studyDays,
        tripTypes: child.tripTypes,
        subscriptionType: child.subscriptionType,
        createdAt: child.createdAt,
        isActive: child.isActive,
      );
    } catch (e) {
      developer.log(
        'خطأ في جلب الطفل $childId: $e',
        name: 'ChildrenRepository',
      );
      return null;
    }
  }

  @override
  Future<bool> updateChild(Child child) async {
    try {
      final childModel = ChildModel.fromEntity(child);

      await _supabase
          .from('children')
          .update(childModel.toJson())
          .eq('child_id', child.id);

      developer.log(
        'تم تحديث بيانات الطفل ${child.name}',
        name: 'ChildrenRepository',
      );
      return true;
    } catch (e) {
      developer.log(
        'خطأ في تحديث الطفل ${child.name}: $e',
        name: 'ChildrenRepository',
      );
      return false;
    }
  }

  @override
  Future<bool> deleteChild(String childId) async {
    try {
      // Soft delete - set is_active to false
      await _supabase
          .from('children')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('child_id', childId);

      developer.log('تم حذف الطفل $childId', name: 'ChildrenRepository');
      return true;
    } catch (e) {
      developer.log(
        'خطأ في حذف الطفل $childId: $e',
        name: 'ChildrenRepository',
      );
      return false;
    }
  }

  @override
  Future<int> getChildrenCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 0;

      final parentResponse = await _supabase
          .from('parents')
          .select('parent_id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (parentResponse == null) return 0;

      final parentId = parentResponse['parent_id'] as String;

      final response = await _supabase
          .from('children')
          .select('child_id')
          .eq('parent_id', parentId)
          .eq('is_active', true);

      return response.length;
    } catch (e) {
      developer.log('خطأ في عد الأطفال: $e', name: 'ChildrenRepository');
      return 0;
    }
  }

  @override
  Future<bool> isChildNameExists(String name) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final parentResponse = await _supabase
          .from('parents')
          .select('parent_id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (parentResponse == null) return false;

      final parentId = parentResponse['parent_id'] as String;

      final response = await _supabase
          .from('children')
          .select('child_id')
          .eq('parent_id', parentId)
          .eq('child_name', name.trim())
          .eq('is_active', true)
          .maybeSingle();

      return response != null;
    } catch (e) {
      developer.log('خطأ في فحص اسم الطفل: $e', name: 'ChildrenRepository');
      return false;
    }
  }
}
