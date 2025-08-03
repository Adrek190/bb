// lib/data/models/bank_model.dart
import '../../domain/entities/bank.dart';

/// نموذج البنك للتعامل مع قاعدة البيانات
class BankModel {
  final String bankId;
  final String bankName;
  final String? bankNameEn;
  final String? bankCode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BankModel({
    required this.bankId,
    required this.bankName,
    this.bankNameEn,
    this.bankCode,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// تحويل من JSON
  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      bankId: json['bank_id'] as String,
      bankName: json['bank_name'] as String,
      bankNameEn: json['bank_name_en'] as String?,
      bankCode: json['bank_code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'bank_id': bankId,
      'bank_name': bankName,
      'bank_name_en': bankNameEn,
      'bank_code': bankCode,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// تحويل من الكيان
  factory BankModel.fromEntity(Bank entity) {
    return BankModel(
      bankId: entity.bankId,
      bankName: entity.bankName,
      bankNameEn: entity.bankNameEn,
      bankCode: entity.bankCode,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// تحويل إلى الكيان
  Bank toEntity() {
    return Bank(
      bankId: bankId,
      bankName: bankName,
      bankNameEn: bankNameEn,
      bankCode: bankCode,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
