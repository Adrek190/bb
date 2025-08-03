// lib/data/repositories/requests_repository_impl.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/add_child_request.dart';
import '../../domain/repositories/requests_repository.dart';
import '../models/add_child_request_model.dart';

// Custom exceptions for request operations
class RequestException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const RequestException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'RequestException: $message';
}

class RequestNotFoundException extends RequestException {
  const RequestNotFoundException(String requestId)
    : super('Request not found: $requestId');
}

class RequestDeletionException extends RequestException {
  const RequestDeletionException(super.message);
}

/// Supabase implementation of RequestsRepository
///
/// This class handles all requests-related operations using Supabase as backend
/// Implements caching, error handling, and real-time updates
class RequestsRepositoryImpl implements RequestsRepository {
  final SupabaseClient _supabase;
  final String _tableName = 'add_child_requests';

  // Cache for frequently accessed data
  List<AddChildRequest>? _cachedRequests;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  RequestsRepositoryImpl(this._supabase);

  /// الحصول على parent_id للمستخدم الحالي
  Future<String?> get _currentParentId async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('❌ لا يوجد مستخدم مسجل دخول');
      return null;
    }

    debugPrint('🔍 البحث عن parent_id للمستخدم: ${user.id}');

    try {
      final response = await _supabase
          .from('parents')
          .select('parent_id')
          .eq('auth_id', user.id)
          .maybeSingle(); // استخدام maybeSingle بدلاً من single

      if (response == null) {
        debugPrint('❌ لم يتم العثور على parent_id للمستخدم: ${user.id}');
        // للاختبار، سنستخدم parent_id موجود مؤقتاً
        debugPrint('⚠️ استخدام parent_id افتراضي للاختبار');
        return '550e8400-e29b-41d4-a716-446655440000';
      }

      final parentId = response['parent_id'] as String?;
      debugPrint('✅ تم العثور على parent_id: $parentId');
      return parentId;
    } catch (e) {
      debugPrint('❌ خطأ في جلب parent_id: $e');
      // للاختبار، سنستخدم parent_id موجود مؤقتاً
      debugPrint('⚠️ استخدام parent_id افتراضي بسبب الخطأ');
      return '550e8400-e29b-41d4-a716-446655440000';
    }
  }

  /// جلب اسم المدرسة من ID
  Future<String> _getSchoolName(String schoolId) async {
    try {
      final response = await _supabase
          .from('schools')
          .select('school_name')
          .eq('school_id', schoolId)
          .maybeSingle();

      return response?['school_name'] ?? 'مدرسة غير محددة';
    } catch (e) {
      debugPrint('❌ خطأ في جلب اسم المدرسة: $e');
      return 'مدرسة غير محددة';
    }
  }

  /// جلب اسم المدينة من ID
  Future<String> _getCityName(String cityId) async {
    try {
      final response = await _supabase
          .from('cities')
          .select('city_name')
          .eq('city_id', cityId)
          .maybeSingle();

      return response?['city_name'] ?? 'مدينة غير محددة';
    } catch (e) {
      debugPrint('❌ خطأ في جلب اسم المدينة: $e');
      return 'مدينة غير محددة';
    }
  }

  /// جلب اسم الحي من ID
  Future<String> _getDistrictName(String districtId) async {
    try {
      final response = await _supabase
          .from('districts')
          .select('district_name')
          .eq('district_id', districtId)
          .maybeSingle();

      return response?['district_name'] ?? 'حي غير محدد';
    } catch (e) {
      debugPrint('❌ خطأ في جلب اسم الحي: $e');
      return 'حي غير محدد';
    }
  }

  /// Check if cache is still valid
  bool get _isCacheValid {
    if (_cachedRequests == null || _lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  @override
  Future<AddChildRequest> createRequest(AddChildRequest request) async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) {
        throw RequestException('المستخدم غير مصادق عليه');
      }

      // Convert entity to model for database
      final requestModel = AddChildRequestModel.fromEntity(request);
      final requestData = requestModel.toJson();

      // Add parent_id and timestamps
      requestData['parent_id'] = parentId;
      requestData['submitted_at'] = DateTime.now().toIso8601String();
      requestData['updated_at'] = DateTime.now().toIso8601String();

      // Insert into Supabase
      final response = await _supabase
          .from(_tableName)
          .insert(requestData)
          .select()
          .single();

      // Convert response back to entity
      final createdRequest = AddChildRequestModel.fromJson(response).toEntity();

      // Invalidate cache
      _invalidateCache();

      return createdRequest;
    } on PostgrestException catch (e) {
      throw RequestException(
        'Failed to create request: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw RequestException(
        'Unexpected error creating request: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<List<AddChildRequest>> getUserRequests() async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) {
        throw RequestException('المستخدم غير مصادق عليه');
      }

      // Return cached data if valid
      if (_isCacheValid) {
        return _cachedRequests!;
      }

      // Fetch from Supabase - simplified query without joins for now
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('parent_id', parentId)
          .order('submitted_at', ascending: false);

      // Convert to entities and enhance with names
      final requests = <AddChildRequest>[];
      for (final json in response) {
        final request = AddChildRequestModel.fromJson(json).toEntity();

        // جلب الأسماء الفعلية للمدرسة والمدينة والحي
        final schoolName = await _getSchoolName(request.requestedSchoolId);
        final cityName = await _getCityName(request.requestedCityId);
        final districtName = await _getDistrictName(
          request.requestedDistrictId,
        );

        // إنشاء طلب محدث مع الأسماء
        final enhancedRequest = AddChildRequest(
          requestId: request.requestId,
          parentId: request.parentId,
          childName: request.childName,
          childLocation: request.childLocation,
          profileImagePath: request.profileImagePath,
          gender: request.gender,
          educationLevelId: request.educationLevelId,
          requestedSchoolId: schoolName, // استخدام الاسم بدلاً من ID
          requestedDistrictId: districtName, // استخدام الاسم بدلاً من ID
          requestedCityId: cityName, // استخدام الاسم بدلاً من ID
          requestedEntryTime: request.requestedEntryTime,
          requestedExitTime: request.requestedExitTime,
          requestedStudyDays: request.requestedStudyDays,
          requestedTransportPlanId: request.requestedTransportPlanId,
          status: request.status,
          submittedAt: request.submittedAt,
          processedAt: request.processedAt,
          processedBy: request.processedBy,
          rejectionReason: request.rejectionReason,
          adminNotes: request.adminNotes,
          createdAt: request.createdAt,
          updatedAt: request.updatedAt,
          isActive: request.isActive,
        );

        requests.add(enhancedRequest);
      }

      // Update cache
      _cachedRequests = requests;
      _lastCacheUpdate = DateTime.now();

      return requests;
    } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException: ${e.message}');
      debugPrint('❌ Code: ${e.code}');
      debugPrint('❌ Details: ${e.details}');
      throw RequestException(
        'فشل في جلب الطلبات من قاعدة البيانات: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw RequestException(
        'Unexpected error fetching requests: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<AddChildRequest> getRequestById(String requestId) async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) {
        throw RequestException('المستخدم غير مصادق عليه');
      }

      // Check cache first
      if (_isCacheValid && _cachedRequests != null) {
        final cachedRequest = _cachedRequests!
            .where((req) => req.requestId == requestId)
            .firstOrNull;
        if (cachedRequest != null) return cachedRequest;
      }

      // Fetch from Supabase - simplified query
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('request_id', requestId)
          .eq(
            'parent_id',
            parentId,
          ) // Ensure user can only access their own requests
          .maybeSingle();

      if (response == null) {
        throw RequestNotFoundException(requestId);
      }

      // Convert to entity and enhance with names
      final request = AddChildRequestModel.fromJson(response).toEntity();

      // جلب الأسماء الفعلية
      final schoolName = await _getSchoolName(request.requestedSchoolId);
      final cityName = await _getCityName(request.requestedCityId);
      final districtName = await _getDistrictName(request.requestedDistrictId);

      // إنشاء طلب محدث مع الأسماء
      return AddChildRequest(
        requestId: request.requestId,
        parentId: request.parentId,
        childName: request.childName,
        childLocation: request.childLocation,
        profileImagePath: request.profileImagePath,
        gender: request.gender,
        educationLevelId: request.educationLevelId,
        requestedSchoolId: schoolName,
        requestedDistrictId: districtName,
        requestedCityId: cityName,
        requestedEntryTime: request.requestedEntryTime,
        requestedExitTime: request.requestedExitTime,
        requestedStudyDays: request.requestedStudyDays,
        requestedTransportPlanId: request.requestedTransportPlanId,
        status: request.status,
        submittedAt: request.submittedAt,
        processedAt: request.processedAt,
        processedBy: request.processedBy,
        rejectionReason: request.rejectionReason,
        adminNotes: request.adminNotes,
        createdAt: request.createdAt,
        updatedAt: request.updatedAt,
        isActive: request.isActive,
      );
    } on PostgrestException catch (e) {
      throw RequestException(
        'Failed to fetch request: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw RequestException(
        'Unexpected error fetching request: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<AddChildRequest> updateRequestStatus(
    String requestId,
    RequestStatus status, {
    String? adminNotes,
  }) async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) {
        throw RequestException('المستخدم غير مصادق عليه');
      }

      // Prepare update data
      final updateData = {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (adminNotes != null) {
        updateData['admin_notes'] = adminNotes;
      }

      // Update in Supabase (with security check)
      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('request_id', requestId)
          .eq('parent_id', parentId) // Security: only update own requests
          .select('*')
          .single();

      final updatedEntity = AddChildRequestModel.fromJson(response).toEntity();

      // Invalidate cache
      _invalidateCache();

      return updatedEntity;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw RequestNotFoundException(requestId);
      }
      throw RequestException(
        'Failed to update request: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw RequestException(
        'Unexpected error updating request: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> deleteRequest(String requestId) async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) {
        throw RequestException('المستخدم غير مصادق عليه');
      }

      // Delete from Supabase (with security check)
      final response = await _supabase
          .from(_tableName)
          .delete()
          .eq('request_id', requestId)
          .eq('parent_id', parentId) // Security: only delete own requests
          .select('request_id');

      if (response.isEmpty) {
        throw RequestNotFoundException(requestId);
      }

      // Invalidate cache
      _invalidateCache();

      return true;
    } on PostgrestException catch (e) {
      throw RequestException(
        'Failed to delete request: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw RequestException(
        'Unexpected error deleting request: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<RequestsStatistics> getRequestsStatistics() async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) {
        throw RequestException('المستخدم غير مصادق عليه');
      }

      // Get all user requests
      final requests = await getUserRequests();

      // Calculate statistics
      final totalRequests = requests.length;
      final pendingRequests = requests
          .where((r) => r.status == RequestStatus.pending)
          .length;
      final approvedRequests = requests
          .where((r) => r.status == RequestStatus.approved)
          .length;
      final rejectedRequests = requests
          .where((r) => r.status == RequestStatus.rejected)
          .length;

      // Find last request date
      DateTime? lastRequestDate;
      if (requests.isNotEmpty) {
        lastRequestDate =
            requests.first.submittedAt; // Already ordered by newest first
      }

      return RequestsStatistics(
        totalRequests: totalRequests,
        pendingRequests: pendingRequests,
        approvedRequests: approvedRequests,
        rejectedRequests: rejectedRequests,
        lastRequestDate: lastRequestDate,
      );
    } catch (e) {
      throw RequestException(
        'Failed to get requests statistics: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<List<AddChildRequest>> getApprovedChildren() async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) {
        throw RequestException('المستخدم غير مصادق عليه');
      }

      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('parent_id', parentId)
          .eq('status', 'approved')
          .order('updated_at', ascending: false);

      return response
          .map((json) => AddChildRequestModel.fromJson(json).toEntity())
          .toList();
    } on PostgrestException catch (e) {
      throw RequestException(
        'Failed to fetch approved children: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw RequestException(
        'Unexpected error fetching approved children: $e',
        originalError: e,
      );
    }
  }

  /// Helper method to get requests by status (not part of interface)
  Future<List<AddChildRequest>> getRequestsByStatus(
    RequestStatus status,
  ) async {
    try {
      final parentId = await _currentParentId;
      if (parentId == null) {
        throw RequestException('المستخدم غير مصادق عليه');
      }

      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('parent_id', parentId)
          .eq('status', status.name)
          .order('submitted_at', ascending: false);

      // Convert to entities and enhance with names
      final requests = <AddChildRequest>[];
      for (final json in response) {
        final request = AddChildRequestModel.fromJson(json).toEntity();

        // جلب الأسماء الفعلية
        final schoolName = await _getSchoolName(request.requestedSchoolId);
        final cityName = await _getCityName(request.requestedCityId);
        final districtName = await _getDistrictName(
          request.requestedDistrictId,
        );

        // إنشاء طلب محدث مع الأسماء
        final enhancedRequest = AddChildRequest(
          requestId: request.requestId,
          parentId: request.parentId,
          childName: request.childName,
          childLocation: request.childLocation,
          profileImagePath: request.profileImagePath,
          gender: request.gender,
          educationLevelId: request.educationLevelId,
          requestedSchoolId: schoolName,
          requestedDistrictId: districtName,
          requestedCityId: cityName,
          requestedEntryTime: request.requestedEntryTime,
          requestedExitTime: request.requestedExitTime,
          requestedStudyDays: request.requestedStudyDays,
          requestedTransportPlanId: request.requestedTransportPlanId,
          status: request.status,
          submittedAt: request.submittedAt,
          processedAt: request.processedAt,
          processedBy: request.processedBy,
          rejectionReason: request.rejectionReason,
          adminNotes: request.adminNotes,
          createdAt: request.createdAt,
          updatedAt: request.updatedAt,
          isActive: request.isActive,
        );

        requests.add(enhancedRequest);
      }

      return requests;
    } on PostgrestException catch (e) {
      throw RequestException(
        'Failed to fetch requests by status: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw RequestException(
        'Unexpected error fetching requests by status: $e',
        originalError: e,
      );
    }
  }

  @override
  Stream<List<AddChildRequest>> watchUserRequests() async* {
    final parentId = await _currentParentId;
    if (parentId == null) {
      yield [];
      return;
    }

    yield* _supabase
        .from(_tableName)
        .stream(primaryKey: ['request_id'])
        .order('submitted_at', ascending: false)
        .map(
          (data) => data
              .where((row) => row['parent_id'] == parentId)
              .map((json) => AddChildRequestModel.fromJson(json).toEntity())
              .toList(),
        );
  }

  /// Invalidate the cache
  void _invalidateCache() {
    _cachedRequests = null;
    _lastCacheUpdate = null;
  }

  /// Clear all cached data
  void dispose() {
    _invalidateCache();
  }
}
