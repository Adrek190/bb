import 'child.dart';

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

  static RequestStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'approved':
        return RequestStatus.approved;
      case 'rejected':
        return RequestStatus.rejected;
      default:
        return RequestStatus.pending;
    }
  }
}

class AddChildRequest {
  final String requestId;
  final String parentId;
  final String childName;
  final String childLocation;
  final String? profileImagePath;
  final Gender gender;
  final String educationLevelId;
  final String requestedSchoolId;
  final String requestedDistrictId;
  final String requestedCityId;
  final DateTime requestedEntryTime;
  final DateTime requestedExitTime;
  final List<String> requestedStudyDays;
  final String requestedTransportPlanId;
  final RequestStatus status;
  final DateTime submittedAt;
  final DateTime? processedAt;
  final String? processedBy;
  final String? rejectionReason;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const AddChildRequest({
    required this.requestId,
    required this.parentId,
    required this.childName,
    required this.childLocation,
    this.profileImagePath,
    required this.gender,
    required this.educationLevelId,
    required this.requestedSchoolId,
    required this.requestedDistrictId,
    required this.requestedCityId,
    required this.requestedEntryTime,
    required this.requestedExitTime,
    required this.requestedStudyDays,
    required this.requestedTransportPlanId,
    required this.status,
    required this.submittedAt,
    this.processedAt,
    this.processedBy,
    this.rejectionReason,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory AddChildRequest.fromJson(Map<String, dynamic> json) {
    return AddChildRequest(
      requestId: json['request_id'] as String,
      parentId: json['parent_id'] as String,
      childName: json['child_name'] as String,
      childLocation: json['child_location'] as String,
      profileImagePath: json['profile_image_path'] as String?,
      gender: GenderExtension.fromString(json['gender'] as String),
      educationLevelId: json['education_level_id'] as String,
      requestedSchoolId: json['requested_school_id'] as String,
      requestedDistrictId: json['requested_district_id'] as String,
      requestedCityId: json['requested_city_id'] as String,
      requestedEntryTime: _parseTime(json['requested_entry_time']),
      requestedExitTime: _parseTime(json['requested_exit_time']),
      requestedStudyDays: List<String>.from(json['requested_study_days'] ?? []),
      requestedTransportPlanId: json['requested_transport_plan_id'] as String,
      status: RequestStatusExtension.fromString(
        json['status'] as String? ?? 'pending',
      ),
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      processedBy: json['processed_by'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static DateTime _parseTime(dynamic timeValue) {
    if (timeValue == null) return DateTime(1970, 1, 1, 7, 0); // Default 07:00
    if (timeValue is String) {
      // Parse time string like "07:00:00"
      final parts = timeValue.split(':');
      final hour = int.tryParse(parts[0]) ?? 7;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return DateTime(1970, 1, 1, hour, minute);
    }
    return DateTime(1970, 1, 1, 7, 0);
  }

  String get formattedEntryTime {
    return '${requestedEntryTime.hour.toString().padLeft(2, '0')}:${requestedEntryTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedExitTime {
    return '${requestedExitTime.hour.toString().padLeft(2, '0')}:${requestedExitTime.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'parent_id': parentId,
      'child_name': childName,
      'child_location': childLocation,
      'profile_image_path': profileImagePath,
      'gender': gender.value,
      'education_level_id': educationLevelId,
      'requested_school_id': requestedSchoolId,
      'requested_district_id': requestedDistrictId,
      'requested_city_id': requestedCityId,
      'requested_entry_time': formattedEntryTime,
      'requested_exit_time': formattedExitTime,
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
    DateTime? requestedEntryTime,
    DateTime? requestedExitTime,
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

  bool get isPending => status == RequestStatus.pending;
  bool get isApproved => status == RequestStatus.approved;
  bool get isRejected => status == RequestStatus.rejected;
  bool get isProcessed => processedAt != null;

  @override
  String toString() {
    return 'AddChildRequest(requestId: $requestId, childName: $childName, status: ${status.displayName}, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddChildRequest && other.requestId == requestId;
  }

  @override
  int get hashCode => requestId.hashCode;
}
