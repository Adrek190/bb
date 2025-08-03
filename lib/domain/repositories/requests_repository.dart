// lib/domain/repositories/requests_repository.dart
import '../entities/add_child_request.dart';

/// Repository interface for managing child addition requests
///
/// This interface defines the contract for all requests-related operations
/// Repository Pattern separates business logic from data access logic
abstract class RequestsRepository {
  /// Create a new child addition request
  ///
  /// [request] - The add child request to create
  /// Returns the created request with generated ID
  /// Throws [RequestException] if creation fails
  Future<AddChildRequest> createRequest(AddChildRequest request);

  /// Get all requests for the authenticated user
  ///
  /// Returns list of user's requests ordered by creation date (newest first)
  /// Returns empty list if no requests found
  /// Throws [RequestException] if fetch fails
  Future<List<AddChildRequest>> getUserRequests();

  /// Get a specific request by ID
  ///
  /// [requestId] - The ID of the request to fetch
  /// Returns the request if found
  /// Throws [RequestNotFoundException] if request not found
  /// Throws [RequestException] if fetch fails
  Future<AddChildRequest> getRequestById(String requestId);

  /// Update request status (usually done by admin)
  ///
  /// [requestId] - The ID of the request to update
  /// [status] - New status for the request
  /// [adminNotes] - Optional notes from admin
  /// Returns the updated request
  /// Throws [RequestNotFoundException] if request not found
  /// Throws [RequestException] if update fails
  Future<AddChildRequest> updateRequestStatus(
    String requestId,
    RequestStatus status, {
    String? adminNotes,
  });

  /// Delete a request (only if status is pending)
  ///
  /// [requestId] - The ID of the request to delete
  /// Returns true if deletion successful
  /// Throws [RequestNotFoundException] if request not found
  /// Throws [RequestDeletionException] if request cannot be deleted
  Future<bool> deleteRequest(String requestId);

  /// Get requests statistics for current user
  ///
  /// Returns summary of requests counts by status
  /// Useful for dashboard display
  Future<RequestsStatistics> getRequestsStatistics();

  /// Listen to real-time updates for user's requests
  ///
  /// Returns a stream that emits when any of user's requests change
  /// Useful for real-time UI updates
  Stream<List<AddChildRequest>> watchUserRequests();

  /// Get approved children for the current user
  ///
  /// Returns list of children whose requests were approved
  /// These are the active children for transportation
  Future<List<AddChildRequest>> getApprovedChildren();
}

/// Statistics model for requests dashboard
class RequestsStatistics {
  final int totalRequests;
  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;
  final DateTime? lastRequestDate;

  const RequestsStatistics({
    required this.totalRequests,
    required this.pendingRequests,
    required this.approvedRequests,
    required this.rejectedRequests,
    this.lastRequestDate,
  });

  /// Calculate approval rate as percentage
  double get approvalRate {
    if (totalRequests == 0) return 0.0;
    return (approvedRequests / totalRequests) * 100;
  }

  /// Check if user has any pending requests
  bool get hasPendingRequests => pendingRequests > 0;

  @override
  String toString() {
    return 'RequestsStatistics(total: $totalRequests, pending: $pendingRequests, approved: $approvedRequests, rejected: $rejectedRequests)';
  }
}

/// Custom exceptions for requests operations
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
    : super('Request not found: $requestId', code: 'REQUEST_NOT_FOUND');
}

class RequestDeletionException extends RequestException {
  const RequestDeletionException(String reason)
    : super('Cannot delete request: $reason', code: 'DELETE_FORBIDDEN');
}
