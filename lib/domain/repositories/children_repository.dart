// lib/domain/repositories/children_repository.dart
import '../entities/child.dart';

/// Repository interface for managing children data
abstract class ChildrenRepository {
  /// Get all approved children for the authenticated parent
  Future<List<Child>> getApprovedChildren();

  /// Get a specific child by ID
  Future<Child?> getChildById(String childId);

  /// Update child information
  Future<bool> updateChild(Child child);

  /// Delete a child (soft delete)
  Future<bool> deleteChild(String childId);

  /// Get children count for the authenticated parent
  Future<int> getChildrenCount();

  /// Check if a child name already exists for the parent
  Future<bool> isChildNameExists(String name);
}
