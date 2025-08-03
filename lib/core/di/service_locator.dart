// lib/core/di/service_locator.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/requests_repository.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/repositories/cities_repository.dart';
import '../../domain/repositories/children_repository.dart';
import '../../data/repositories/requests_repository_impl.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../data/repositories/cities_repository_impl.dart';
import '../../data/repositories/children_repository_impl.dart';

/// Simple Service Locator for Dependency Injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Dependencies storage
  final Map<Type, dynamic> _services = {};

  /// Register a service
  void register<T>(T service) {
    _services[T] = service;
  }

  /// Get a service
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered');
    }
    return service as T;
  }

  /// Check if service is registered
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Clear all services (useful for testing)
  void clear() {
    _services.clear();
  }
}

/// Global service locator instance
final serviceLocator = ServiceLocator();

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // External dependencies
  serviceLocator.register<SupabaseClient>(Supabase.instance.client);

  // Repositories
  serviceLocator.register<RequestsRepository>(
    RequestsRepositoryImpl(serviceLocator.get<SupabaseClient>()),
  );

  serviceLocator.register<NotificationsRepository>(
    NotificationsRepositoryImpl(),
  );

  serviceLocator.register<CitiesRepository>(CitiesRepositoryImpl());

  serviceLocator.register<ChildrenRepository>(ChildrenRepositoryImpl());
}

/// Helper functions for easy access
extension ServiceLocatorExtensions on ServiceLocator {
  RequestsRepository get requestsRepository => get<RequestsRepository>();
  NotificationsRepository get notificationsRepository =>
      get<NotificationsRepository>();
  CitiesRepository get citiesRepository => get<CitiesRepository>();
  ChildrenRepository get childrenRepository => get<ChildrenRepository>();
  SupabaseClient get supabaseClient => get<SupabaseClient>();
}
