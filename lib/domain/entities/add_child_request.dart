import '../../core/models/gender.dart';

/// حالات طلب إضافة الطفل
enum RequestStatus {
  pending, // قيد المراجعة
  approved, // مقبول
  rejected, // مرفوض
}

extension RequestStatusExtension on RequestStatus {
  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'قيد المراجعة';
      case RequestStatus.approved:
        return 'مقبول';
      case RequestStatus.rejected:
        return 'مرفوض';
    }
  }

  String get statusKey {
    switch (this) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.approved:
        return 'approved';
      case RequestStatus.rejected:
        return 'rejected';
    }
  }
}

/// نموذج طلب إضافة طفل - يطابق جدول add_child_requests
class AddChildRequest {
  // المعرفات الأساسية
  final String requestId;
  final String parentId;

  // معلومات الطفل الأساسية
  final String childName;
  final String childLocation;
  final String? profileImagePath;
  final Gender gender;

  // معلومات التعليم
  final String educationLevelId;

  // معلومات المدرسة والموقع
  final String requestedSchoolId;
  final String requestedDistrictId;
  final String requestedCityId;

  // معلومات التوقيت
  final String requestedEntryTime; // "07:30"
  final String requestedExitTime; // "14:00"
  final List<String> requestedStudyDays; // ["sunday", "monday", ...]

  // خطة النقل
  final String requestedTransportPlanId;

  // حالة الطلب
  final RequestStatus status;
  final DateTime submittedAt;
  final DateTime? processedAt;
  final String? processedBy;
  final String? rejectionReason;
  final String? adminNotes;

  // معلومات النظام
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  AddChildRequest({
    required this.requestId,
    required this.parentId,
    required this.childName,
    required this.childLocation,
    required this.gender,
    required this.educationLevelId,
    required this.requestedSchoolId,
    required this.requestedDistrictId,
    required this.requestedCityId,
    required this.requestedEntryTime,
    required this.requestedExitTime,
    required this.requestedStudyDays,
    required this.requestedTransportPlanId,
    this.profileImagePath,
    this.status = RequestStatus.pending,
    DateTime? submittedAt,
    this.processedAt,
    this.processedBy,
    this.rejectionReason,
    this.adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  }) : submittedAt = submittedAt ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Getter للتوافق مع الأكواد القديمة
  String get id => requestId;

  /// تحويل إلى Map للحفظ في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'request_id': requestId,
      'parent_id': parentId,
      'child_name': childName,
      'child_location': childLocation,
      'profile_image_path': profileImagePath,
      'gender': gender.key,
      'education_level_id': educationLevelId,
      'requested_school_id': requestedSchoolId,
      'requested_district_id': requestedDistrictId,
      'requested_city_id': requestedCityId,
      'requested_entry_time': requestedEntryTime,
      'requested_exit_time': requestedExitTime,
      'requested_study_days': requestedStudyDays,
      'requested_transport_plan_id': requestedTransportPlanId,
      'status': status.statusKey,
      'submitted_at': submittedAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'processed_by': processedBy,
      'rejection_reason': rejectionReason,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// إنشاء من Map (من قاعدة البيانات)
  factory AddChildRequest.fromMap(Map<String, dynamic> map) {
    return AddChildRequest(
      requestId: map['request_id'] ?? map['id'] ?? '',
      parentId: map['parent_id'] ?? '',
      childName: map['child_name'] ?? map['childName'] ?? '',
      childLocation: map['child_location'] ?? '',
      profileImagePath: map['profile_image_path'],
      gender: GenderExtension.fromKey(map['gender'] ?? 'male'),
      educationLevelId: map['education_level_id'] ?? '',
      requestedSchoolId: map['requested_school_id'] ?? '',
      requestedDistrictId: map['requested_district_id'] ?? '',
      requestedCityId: map['requested_city_id'] ?? '',
      requestedEntryTime: map['requested_entry_time'] ?? '',
      requestedExitTime: map['requested_exit_time'] ?? '',
      requestedStudyDays: List<String>.from(map['requested_study_days'] ?? []),
      requestedTransportPlanId: map['requested_transport_plan_id'] ?? '',
      status: _statusFromString(map['status'] ?? 'pending'),
      submittedAt:
          DateTime.tryParse(map['submitted_at'] ?? map['submittedAt'] ?? '') ??
          DateTime.now(),
      processedAt: map['processed_at'] != null
          ? DateTime.tryParse(map['processed_at'])
          : null,
      processedBy: map['processed_by'],
      rejectionReason: map['rejection_reason'] ?? map['rejectionReason'],
      adminNotes: map['admin_notes'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      isActive: map['is_active'] ?? true,
    );
  }

  /// تحويل نص الحالة إلى enum
  static RequestStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return RequestStatus.approved;
      case 'rejected':
        return RequestStatus.rejected;
      case 'pending':
      default:
        return RequestStatus.pending;
    }
  }

  /// إنشاء نسخة مع تعديلات
  AddChildRequest copyWith({
    String? requestId,
    String? parentId,
    String? childName,
    String? childLocation,
    String? profileImagePath,
    Gender? gender,
    String? educationLevelId,
    String? requestedSchoolId,
    String? requestedDistrictId,
    String? requestedCityId,
    String? requestedEntryTime,
    String? requestedExitTime,
    List<String>? requestedStudyDays,
    String? requestedTransportPlanId,
    RequestStatus? status,
    DateTime? submittedAt,
    DateTime? processedAt,
    String? processedBy,
    String? rejectionReason,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return AddChildRequest(
      requestId: requestId ?? this.requestId,
      parentId: parentId ?? this.parentId,
      childName: childName ?? this.childName,
      childLocation: childLocation ?? this.childLocation,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      gender: gender ?? this.gender,
      educationLevelId: educationLevelId ?? this.educationLevelId,
      requestedSchoolId: requestedSchoolId ?? this.requestedSchoolId,
      requestedDistrictId: requestedDistrictId ?? this.requestedDistrictId,
      requestedCityId: requestedCityId ?? this.requestedCityId,
      requestedEntryTime: requestedEntryTime ?? this.requestedEntryTime,
      requestedExitTime: requestedExitTime ?? this.requestedExitTime,
      requestedStudyDays: requestedStudyDays ?? this.requestedStudyDays,
      requestedTransportPlanId:
          requestedTransportPlanId ?? this.requestedTransportPlanId,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      processedAt: processedAt ?? this.processedAt,
      processedBy: processedBy ?? this.processedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// معلومات مختصرة للعرض
  String get displayInfo => '$childName - ${status.displayName}';

  /// هل الطلب قابل للتعديل؟
  bool get canEdit => status == RequestStatus.pending;

  /// هل الطلب مقبول؟
  bool get isApproved => status == RequestStatus.approved;

  /// هل الطلب مرفوض؟
  bool get isRejected => status == RequestStatus.rejected;

  @override
  String toString() {
    return 'AddChildRequest{requestId: $requestId, childName: $childName, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddChildRequest && other.requestId == requestId;
  }

  @override
  int get hashCode => requestId.hashCode;
}
