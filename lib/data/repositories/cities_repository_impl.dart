// lib/data/repositories/cities_repository_impl.dart
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/district.dart';
import '../../domain/entities/school.dart';
import '../../domain/entities/education_level.dart';
import '../../domain/entities/transport_plan.dart';
import '../../domain/entities/study_day.dart';
import '../../domain/repositories/cities_repository.dart';
import '../models/city_model.dart';
import '../models/district_model.dart';
import '../models/school_model.dart';
import '../models/education_level_model.dart';
import '../models/transport_plan_model.dart';
import '../models/study_day_model.dart';

/// Supabase implementation of CitiesRepository
class CitiesRepositoryImpl implements CitiesRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Simple cache for cities data (since it doesn't change often)
  List<City>? _cachedCities;
  final Map<String, List<District>> _cachedDistricts = {};
  final Map<String, List<School>> _cachedSchools = {};

  @override
  Future<List<City>> getCities() async {
    try {
      // Return cached data if available
      if (_cachedCities != null) {
        return _cachedCities!;
      }

      final response = await _supabase
          .from('cities')
          .select()
          .order('city_name');

      final cities = response
          .map<City>((json) => CityModel.fromJson(json).toEntity())
          .toList();

      // Cache the results
      _cachedCities = cities;

      return cities;
    } catch (e) {
      developer.log('خطأ في جلب المدن: $e', name: 'CitiesRepository');
      return [];
    }
  }

  @override
  Future<List<District>> getDistrictsByCity(String cityId) async {
    try {
      // Check cache first
      if (_cachedDistricts.containsKey(cityId)) {
        return _cachedDistricts[cityId]!;
      }

      final response = await _supabase
          .from('districts')
          .select()
          .eq('city_id', cityId)
          .order('district_name');

      final districts = response
          .map<District>((json) => DistrictModel.fromJson(json).toEntity())
          .toList();

      // Cache the results
      _cachedDistricts[cityId] = districts;

      return districts;
    } catch (e) {
      developer.log(
        'خطأ في جلب المناطق للمدينة $cityId: $e',
        name: 'CitiesRepository',
      );
      return [];
    }
  }

  @override
  Future<List<School>> getSchoolsByDistrict(String districtId) async {
    try {
      // Check cache first
      if (_cachedSchools.containsKey(districtId)) {
        return _cachedSchools[districtId]!;
      }

      final response = await _supabase
          .from('schools')
          .select('''
            school_id,
            school_name,
            school_type,
            education_level_id,
            district_id,
            full_address,
            phone,
            email,
            operating_hours_start,
            operating_hours_end,
            working_days,
            capacity,
            current_students,
            is_transport_available,
            is_active,
            created_at,
            updated_at,
            education_levels!inner(id, name),
            districts!inner(district_id, district_name, cities!inner(city_id, city_name))
          ''')
          .eq('district_id', districtId)
          .eq('is_active', true)
          .order('school_name');

      final schools = response.map<School>((json) {
        // استخراج المعلومات من الجداول المرتبطة
        final educationLevel = json['education_levels'] as Map<String, dynamic>;
        final district = json['districts'] as Map<String, dynamic>;
        final city = district['cities'] as Map<String, dynamic>;

        return SchoolModel.fromJson(json).toEntity(
          educationLevelName: educationLevel['name'] as String,
          districtName: district['district_name'] as String,
          cityName: city['city_name'] as String,
        );
      }).toList();

      // Cache the results
      _cachedSchools[districtId] = schools;

      return schools;
    } catch (e) {
      developer.log(
        'خطأ في جلب المدارس للمنطقة $districtId: $e',
        name: 'CitiesRepository',
      );
      return [];
    }
  }

  @override
  Future<City?> getCityById(String cityId) async {
    try {
      // Check cached cities first
      if (_cachedCities != null) {
        final city = _cachedCities!
            .where((c) => c.cityId == cityId)
            .firstOrNull;
        if (city != null) return city;
      }

      final response = await _supabase
          .from('cities')
          .select()
          .eq('city_id', cityId)
          .maybeSingle();

      if (response == null) return null;

      return CityModel.fromJson(response).toEntity();
    } catch (e) {
      developer.log('خطأ في جلب المدينة $cityId: $e', name: 'CitiesRepository');
      return null;
    }
  }

  @override
  Future<District?> getDistrictById(String districtId) async {
    try {
      final response = await _supabase
          .from('districts')
          .select()
          .eq('district_id', districtId)
          .maybeSingle();

      if (response == null) return null;

      return DistrictModel.fromJson(response).toEntity();
    } catch (e) {
      developer.log(
        'خطأ في جلب المنطقة $districtId: $e',
        name: 'CitiesRepository',
      );
      return null;
    }
  }

  @override
  Future<School?> getSchoolById(String schoolId) async {
    try {
      final response = await _supabase
          .from('schools')
          .select('''
            school_id,
            school_name,
            school_type,
            education_level_id,
            district_id,
            full_address,
            phone,
            email,
            operating_hours_start,
            operating_hours_end,
            working_days,
            capacity,
            current_students,
            is_transport_available,
            is_active,
            created_at,
            updated_at,
            education_levels!inner(id, name),
            districts!inner(district_id, district_name, cities!inner(city_id, city_name))
          ''')
          .eq('school_id', schoolId)
          .maybeSingle();

      if (response == null) return null;

      final educationLevel =
          response['education_levels'] as Map<String, dynamic>;
      final district = response['districts'] as Map<String, dynamic>;
      final city = district['cities'] as Map<String, dynamic>;

      return SchoolModel.fromJson(response).toEntity(
        educationLevelName: educationLevel['name'] as String,
        districtName: district['district_name'] as String,
        cityName: city['city_name'] as String,
      );
    } catch (e) {
      developer.log(
        'خطأ في جلب المدرسة $schoolId: $e',
        name: 'CitiesRepository',
      );
      return null;
    }
  }

  /// Clear all cached data
  void clearCache() {
    _cachedCities = null;
    _cachedDistricts.clear();
    _cachedSchools.clear();
  }

  @override
  Future<List<School>> getSchoolsByCity(String cityId) async {
    try {
      final response = await _supabase
          .from('schools')
          .select('''
            school_id,
            school_name,
            school_type,
            education_level_id,
            district_id,
            full_address,
            phone,
            email,
            operating_hours_start,
            operating_hours_end,
            working_days,
            capacity,
            current_students,
            is_transport_available,
            is_active,
            created_at,
            updated_at,
            education_levels!inner(id, name),
            districts!inner(district_id, district_name, city_id, cities!inner(city_id, city_name))
          ''')
          .eq('districts.city_id', cityId)
          .eq('is_active', true)
          .order('school_name');

      final schools = response.map<School>((json) {
        final educationLevel = json['education_levels'] as Map<String, dynamic>;
        final district = json['districts'] as Map<String, dynamic>;
        final city = district['cities'] as Map<String, dynamic>;

        return SchoolModel.fromJson(json).toEntity(
          educationLevelName: educationLevel['name'] as String,
          districtName: district['district_name'] as String,
          cityName: city['city_name'] as String,
        );
      }).toList();

      return schools;
    } catch (e) {
      developer.log(
        'خطأ في جلب المدارس للمدينة $cityId: $e',
        name: 'CitiesRepository',
      );
      return [];
    }
  }

  @override
  Future<List<EducationLevel>> getEducationLevels() async {
    try {
      final response = await _supabase
          .from('education_levels')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      final educationLevels = response
          .map<EducationLevel>(
            (json) => EducationLevelModel.fromJson(json).toEntity(),
          )
          .toList();

      return educationLevels;
    } catch (e) {
      developer.log(
        'خطأ في جلب المراحل التعليمية: $e',
        name: 'CitiesRepository',
      );
      return [];
    }
  }

  @override
  Future<List<TransportPlan>> getTransportPlans() async {
    try {
      final response = await _supabase
          .from('transport_plans')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      final transportPlans = response
          .map<TransportPlan>(
            (json) => TransportPlanModel.fromJson(json).toEntity(),
          )
          .toList();

      return transportPlans;
    } catch (e) {
      developer.log('خطأ في جلب خطط النقل: $e', name: 'CitiesRepository');
      return [];
    }
  }

  @override
  Future<List<StudyDay>> getStudyDays() async {
    try {
      final response = await _supabase
          .from('study_days')
          .select()
          .eq('is_active', true)
          .order('day_order');

      final studyDays = response
          .map<StudyDay>((json) => StudyDayModel.fromJson(json).toEntity())
          .toList();

      return studyDays;
    } catch (e) {
      developer.log('خطأ في جلب أيام الدراسة: $e', name: 'CitiesRepository');
      return [];
    }
  }

  @override
  Future<List<StudyDay>> getWorkingStudyDays() async {
    try {
      final response = await _supabase
          .from('study_days')
          .select()
          .eq('is_active', true)
          .eq('is_weekend', false)
          .order('day_order');

      final workingDays = response
          .map<StudyDay>((json) => StudyDayModel.fromJson(json).toEntity())
          .toList();

      return workingDays;
    } catch (e) {
      developer.log('خطأ في جلب أيام العمل: $e', name: 'CitiesRepository');
      return [];
    }
  }

  @override
  Future<List<School>> searchSchools(String query) async {
    try {
      final response = await _supabase
          .from('schools')
          .select('''
            school_id,
            school_name,
            school_type,
            education_level_id,
            district_id,
            full_address,
            phone,
            email,
            operating_hours_start,
            operating_hours_end,
            working_days,
            capacity,
            current_students,
            is_transport_available,
            is_active,
            created_at,
            updated_at,
            education_levels!inner(id, name),
            districts!inner(district_id, district_name, cities!inner(city_id, city_name))
          ''')
          .ilike('school_name', '%$query%')
          .eq('is_active', true)
          .order('school_name');

      final schools = response.map<School>((json) {
        final educationLevel = json['education_levels'] as Map<String, dynamic>;
        final district = json['districts'] as Map<String, dynamic>;
        final city = district['cities'] as Map<String, dynamic>;

        return SchoolModel.fromJson(json).toEntity(
          educationLevelName: educationLevel['name'] as String,
          districtName: district['district_name'] as String,
          cityName: city['city_name'] as String,
        );
      }).toList();

      return schools;
    } catch (e) {
      developer.log('خطأ في البحث عن المدارس: $e', name: 'CitiesRepository');
      return [];
    }
  }
}
