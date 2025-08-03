// lib/domain/entities/bank.dart

/// كيان البنك
class Bank {
  final String bankId;
  final String bankName;
  final String? bankNameEn;
  final String? bankCode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Bank({
    required this.bankId,
    required this.bankName,
    this.bankNameEn,
    this.bankCode,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// نسخ الكيان مع تحديث بعض الخصائص
  Bank copyWith({
    String? bankId,
    String? bankName,
    String? bankNameEn,
    String? bankCode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bank(
      bankId: bankId ?? this.bankId,
      bankName: bankName ?? this.bankName,
      bankNameEn: bankNameEn ?? this.bankNameEn,
      bankCode: bankCode ?? this.bankCode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Bank(bankId: $bankId, bankName: $bankName, isActive: $isActive)';
  }
}
