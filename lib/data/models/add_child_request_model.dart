import '../../domain/entities/add_child_request.dart';
import '../../core/models/gender.dart';

/// Data model for AddChildRequest that handles database serialization
///
/// This model converts between the domain entity and database JSON format
/// It handles Supabase-specific field mappings and data types
class AddChildRequestModel {
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
  final String requestedEntryTime; // "07:30" format
  final String requestedExitTime; // "15:30" format
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

  const AddChildRequestModel({
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

  /// Convert database JSON to model
  factory AddChildRequestModel.fromJson(Map<String, dynamic> json) {
    return AddChildRequestModel(
      requestId: json['request_id'] as String,
      parentId: json['parent_id'] as String,
      childName: json['child_name'] as String,
      childLocation: json['child_location'] as String,
      profileImagePath: json['profile_image_path'] as String?,
      gender: GenderExtension.fromKey(json['gender'] as String),
      educationLevelId: json['education_level_id'] as String,
      requestedSchoolId: json['requested_school_id'] as String,
      requestedDistrictId: json['requested_district_id'] as String,
      requestedCityId: json['requested_city_id'] as String,
      requestedEntryTime: _parseTimeToString(json['requested_entry_time']),
      requestedExitTime: _parseTimeToString(json['requested_exit_time']),
      requestedStudyDays: List<String>.from(json['requested_study_days'] ?? []),
      requestedTransportPlanId: json['requested_transport_plan_id'] as String,
      status: _statusFromString(json['status'] as String? ?? 'pending'),
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

  /// Convert model to database JSON
  Map<String, dynamic> toJson() {
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

  /// Convert from domain entity to model
  factory AddChildRequestModel.fromEntity(AddChildRequest entity) {
    return AddChildRequestModel(
      requestId: entity.requestId,
      parentId: entity.parentId,
      childName: entity.childName,
      childLocation: entity.childLocation,
      profileImagePath: entity.profileImagePath,
      gender: entity.gender,
      educationLevelId: entity.educationLevelId,
      requestedSchoolId: entity.requestedSchoolId,
      requestedDistrictId: entity.requestedDistrictId,
      requestedCityId: entity.requestedCityId,
      requestedEntryTime: entity.requestedEntryTime,
      requestedExitTime: entity.requestedExitTime,
      requestedStudyDays: entity.requestedStudyDays,
      requestedTransportPlanId: entity.requestedTransportPlanId,
      status: entity.status,
      submittedAt: entity.submittedAt,
      processedAt: entity.processedAt,
      processedBy: entity.processedBy,
      rejectionReason: entity.rejectionReason,
      adminNotes: entity.adminNotes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
    );
  }

  /// Convert model to domain entity
  AddChildRequest toEntity() {
    return AddChildRequest(
      requestId: requestId,
      parentId: parentId,
      childName: childName,
      childLocation: childLocation,
      profileImagePath: profileImagePath,
      gender: gender,
      educationLevelId: educationLevelId,
      requestedSchoolId: requestedSchoolId,
      requestedDistrictId: requestedDistrictId,
      requestedCityId: requestedCityId,
      requestedEntryTime: requestedEntryTime,
      requestedExitTime: requestedExitTime,
      requestedStudyDays: requestedStudyDays,
      requestedTransportPlanId: requestedTransportPlanId,
      status: status,
      submittedAt: submittedAt,
      processedAt: processedAt,
      processedBy: processedBy,
      rejectionReason: rejectionReason,
      adminNotes: adminNotes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  /// Helper method to parse time from database to string format
  static String _parseTimeToString(dynamic timeValue) {
    if (timeValue == null) return '07:00'; // Default 07:00
    if (timeValue is String) {
      // If already a string like "07:00:00", convert to "07:00"
      final parts = timeValue.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return timeValue;
    }
    return '07:00';
  }

  /// Helper method to parse status from string
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

  @override
  String toString() {
    return 'AddChildRequestModel(requestId: $requestId, childName: $childName, status: ${status.statusKey})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddChildRequestModel && other.requestId == requestId;
  }

  @override
  int get hashCode => requestId.hashCode;
}
