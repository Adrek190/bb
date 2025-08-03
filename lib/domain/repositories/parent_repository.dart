import '../entities/parent_entity.dart';

/// Repository interface for parent-related operations
///
/// This interface defines the contract for all parent data operations
/// Repository Pattern separates business logic from data access logic
abstract class ParentRepository {
  /// Get current parent profile
  ///
  /// Returns the parent profile for the authenticated user
  /// Throws [ParentException] if fetch fails
  /// Throws [ParentNotFoundException] if parent not found
  Future<ParentEntity> getCurrentParent();

  /// Update parent profile
  ///
  /// [parent] - The updated parent data
  /// Returns the updated parent entity
  /// Throws [ParentException] if update fails
  Future<ParentEntity> updateParent(ParentEntity parent);

  /// Update parent name
  ///
  /// [parentId] - The parent ID
  /// [newName] - The new name
  /// Returns the updated parent entity
  /// Throws [ParentException] if update fails
  Future<ParentEntity> updateParentName(String parentId, String newName);

  /// Update parent email
  ///
  /// [parentId] - The parent ID
  /// [newEmail] - The new email
  /// Returns the updated parent entity
  /// Throws [ParentException] if update fails
  Future<ParentEntity> updateParentEmail(String parentId, String newEmail);

  /// Update parent phone
  ///
  /// [parentId] - The parent ID
  /// [newPhone] - The new phone number
  /// Returns the updated parent entity
  /// Throws [ParentException] if update fails
  Future<ParentEntity> updateParentPhone(String parentId, String newPhone);

  /// Update parent profile image
  ///
  /// [parentId] - The parent ID
  /// [imageUrl] - The new profile image URL
  /// Returns the updated parent entity
  /// Throws [ParentException] if update fails
  Future<ParentEntity> updateParentProfileImage(
    String parentId,
    String imageUrl,
  );

  /// Upload profile image
  ///
  /// [parentId] - The parent ID
  /// [imagePath] - The local image file path
  /// Returns the uploaded image URL
  /// Throws [ParentException] if upload fails
  Future<String> uploadProfileImage(String parentId, String imagePath);

  /// Update last login timestamp
  ///
  /// [parentId] - The parent ID
  /// Returns the updated parent entity
  /// Throws [ParentException] if update fails
  Future<ParentEntity> updateLastLogin(String parentId);

  /// Get parent by auth ID
  ///
  /// [authId] - The Supabase auth user ID
  /// Returns the parent entity if found
  /// Throws [ParentNotFoundException] if not found
  /// Throws [ParentException] if fetch fails
  Future<ParentEntity> getParentByAuthId(String authId);
}

/// Exception for parent operations
class ParentException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const ParentException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'ParentException: $message';
}

/// Exception when parent is not found
class ParentNotFoundException extends ParentException {
  const ParentNotFoundException(super.message);
}
