// lib/domain/repositories/cities_repository.dart
import '../entities/city.dart';
import '../entities/district.dart';
import '../entities/school.dart';
import '../entities/education_level.dart';
import '../entities/transport_plan.dart';
import '../entities/study_day.dart';

/// Repository interface for cities, districts, schools and related data
abstract class CitiesRepository {
  /// Get all active cities
  Future<List<City>> getCities();

  /// Get districts by city ID
  Future<List<District>> getDistrictsByCity(String cityId);

  /// Get schools by district ID
  Future<List<School>> getSchoolsByDistrict(String districtId);

  /// Get schools by city ID
  Future<List<School>> getSchoolsByCity(String cityId);

  /// Get education levels
  Future<List<EducationLevel>> getEducationLevels();

  /// Get transport plans
  Future<List<TransportPlan>> getTransportPlans();

  /// Get study days
  Future<List<StudyDay>> getStudyDays();

  /// Get working study days only (exclude weekends)
  Future<List<StudyDay>> getWorkingStudyDays();

  /// Search schools by name
  Future<List<School>> searchSchools(String query);

  /// Get school by ID
  Future<School?> getSchoolById(String schoolId);

  /// Get a specific city by ID
  Future<City?> getCityById(String cityId);

  /// Get a specific district by ID
  Future<District?> getDistrictById(String districtId);
}
