import 'package:flutter/material.dart';
import '../../domain/entities/add_child_request.dart';
import '../../domain/repositories/requests_repository.dart';
import './notifications_provider.dart';

/// Provider for managing child addition requests with complete functionality
///
/// Features:
/// - CRUD operations for requests
/// - Real-time status updates
/// - Statistics and filtering
/// - Integration with notifications
/// - Pull-to-refresh support
/// - Search and sorting capabilities
class RequestsProvider extends ChangeNotifier {
  final RequestsRepository _repository;
  final NotificationsProvider? _notificationsProvider;

  RequestsProvider(
    this._repository, {
    NotificationsProvider? notificationsProvider,
  }) : _notificationsProvider = notificationsProvider;

  // State
  List<AddChildRequest> _requests = [];
  Map<RequestStatus, int> _statistics = {};
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdate;

  // Getters
  List<AddChildRequest> get requests => _requests;
  Map<RequestStatus, int> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdate => _lastUpdate;

  // Filtered lists for dashboard
  List<AddChildRequest> get pendingRequests =>
      _requests.where((r) => r.status == RequestStatus.pending).toList();

  List<AddChildRequest> get approvedRequests =>
      _requests.where((r) => r.status == RequestStatus.approved).toList();

  List<AddChildRequest> get rejectedRequests =>
      _requests.where((r) => r.status == RequestStatus.rejected).toList();

  // Summary counts for quick access
  int get totalRequests => _requests.length;
  int get pendingCount => pendingRequests.length;
  int get approvedCount => approvedRequests.length;
  int get rejectedCount => rejectedRequests.length;

  bool get hasRequests => _requests.isNotEmpty;

  /// Initialize provider and load data
  Future<void> initialize() async {
    await loadRequests();
  }

  /// Load all requests for current user
  Future<void> loadRequests({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _setLoading(true);
    _clearError();

    try {
      _requests = await _repository.getUserRequests();
      _updateStatistics();
      _lastUpdate = DateTime.now();

      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new request
  Future<AddChildRequest?> createRequest(AddChildRequest request) async {
    if (_isLoading) return null;

    _setLoading(true);
    _clearError();

    try {
      final createdRequest = await _repository.createRequest(request);

      // Add to local list at the beginning (newest first)
      _requests.insert(0, createdRequest);
      _updateStatistics();

      // Create notification for request submission
      await _createRequestNotification(
        createdRequest.requestId,
        'تم إرسال الطلب بنجاح',
        'تم إرسال طلب إضافة طفل جديد وهو الآن قيد المراجعة',
        'info',
      );

      notifyListeners();
      return createdRequest;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get request by ID
  Future<AddChildRequest?> getRequestById(String requestId) async {
    try {
      // Check local cache first
      final localRequest = _requests
          .where((r) => r.requestId == requestId)
          .firstOrNull;

      if (localRequest != null) {
        return localRequest;
      }

      // Fetch from repository
      return await _repository.getRequestById(requestId);
    } catch (e) {
      _setError(_getErrorMessage(e));
      return null;
    }
  }

  /// Update request status (admin function)
  Future<bool> updateRequestStatus(
    String requestId,
    RequestStatus status, {
    String? adminNotes,
  }) async {
    try {
      final updatedRequest = await _repository.updateRequestStatus(
        requestId,
        status,
        adminNotes: adminNotes,
      );

      // Update local list
      final index = _requests.indexWhere((r) => r.requestId == requestId);
      if (index != -1) {
        final oldStatus = _requests[index].status;
        _requests[index] = updatedRequest;

        // Create notification for status change
        if (oldStatus != status) {
          await _createStatusChangeNotification(requestId, status);
        }

        _updateStatistics();
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  /// Delete request (only if pending)
  Future<bool> deleteRequest(String requestId) async {
    try {
      await _repository.deleteRequest(requestId);

      // Remove from local list
      _requests.removeWhere((r) => r.requestId == requestId);
      _updateStatistics();
      notifyListeners();

      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  /// Get requests by status
  List<AddChildRequest> getRequestsByStatus(RequestStatus status) {
    return _requests.where((r) => r.status == status).toList();
  }

  /// Filter requests by date range
  List<AddChildRequest> getRequestsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _requests.where((r) {
      return r.submittedAt.isAfter(startDate) &&
          r.submittedAt.isBefore(endDate);
    }).toList();
  }

  /// Search requests by child name
  List<AddChildRequest> searchRequests(String query) {
    if (query.isEmpty) return _requests;

    final lowerQuery = query.toLowerCase();
    return _requests.where((r) {
      return r.childName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get recent requests (last 30 days)
  List<AddChildRequest> getRecentRequests() {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    return _requests.where((r) => r.submittedAt.isAfter(monthAgo)).toList();
  }

  /// Sort requests by date
  void sortRequestsByDate({bool ascending = false}) {
    _requests.sort((a, b) {
      return ascending
          ? a.submittedAt.compareTo(b.submittedAt)
          : b.submittedAt.compareTo(a.submittedAt);
    });
    notifyListeners();
  }

  /// Sort requests by status
  void sortRequestsByStatus() {
    // Order: pending -> approved -> rejected
    final statusOrder = {
      RequestStatus.pending: 0,
      RequestStatus.approved: 1,
      RequestStatus.rejected: 2,
    };

    _requests.sort((a, b) {
      final aOrder = statusOrder[a.status] ?? 3;
      final bOrder = statusOrder[b.status] ?? 3;
      return aOrder.compareTo(bOrder);
    });
    notifyListeners();
  }

  /// Refresh data (pull-to-refresh)
  Future<void> refresh() async {
    await loadRequests(forceRefresh: true);
  }

  /// Clear all data
  void clear() {
    _requests.clear();
    _statistics.clear();
    _lastUpdate = null;
    _clearError();
    notifyListeners();
  }

  /// Create notification for request-related events
  Future<void> _createRequestNotification(
    String requestId,
    String title,
    String message,
    String type,
  ) async {
    try {
      if (_notificationsProvider != null) {
        await _notificationsProvider.createRequestStatusNotification(
          requestId,
          type,
        );
      }
    } catch (e) {
      // Silent fail - don't disrupt main flow
      debugPrint('Failed to create request notification: $e');
    }
  }

  /// Create notification for status changes
  Future<void> _createStatusChangeNotification(
    String requestId,
    RequestStatus status,
  ) async {
    final statusString = status.name;
    await _createRequestNotification(
      requestId,
      'تحديث حالة الطلب',
      'تم تحديث حالة طلبك إلى: ${_getStatusDisplayName(status)}',
      statusString,
    );
  }

  /// Get display name for status
  String _getStatusDisplayName(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'قيد المراجعة';
      case RequestStatus.approved:
        return 'مقبول';
      case RequestStatus.rejected:
        return 'مرفوض';
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _updateStatistics() {
    _statistics = {
      RequestStatus.pending: pendingRequests.length,
      RequestStatus.approved: approvedRequests.length,
      RequestStatus.rejected: rejectedRequests.length,
    };
  }

  String _getErrorMessage(dynamic error) {
    if (error is RequestException) {
      return error.message;
    }
    return 'حدث خطأ غير متوقع: ${error.toString()}';
  }
}
