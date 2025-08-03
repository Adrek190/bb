// lib/data/models/bill_model.dart
import '../../domain/entities/bill.dart';

/// نموذج الفاتورة للتعامل مع قاعدة البيانات
class BillModel {
  final String billId;
  final String parentId;
  final String? relatedRequestId;
  final String billNumber;
  final String billDescription;
  final double amount;
  final double paidAmount;
  final String? bankId;
  final String? bankName;
  final String? transferNumber;
  final String? receiptImagePath;
  final String status;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? adminNotes;
  final String? paymentNotes;
  final bool isActive;
  final String? childName;
  final String? schoolName;
  final String? cityName;
  final String? districtName;

  const BillModel({
    required this.billId,
    required this.parentId,
    this.relatedRequestId,
    required this.billNumber,
    required this.billDescription,
    required this.amount,
    this.paidAmount = 0.0,
    this.bankId,
    this.bankName,
    this.transferNumber,
    this.receiptImagePath,
    required this.status,
    this.dueDate,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
    this.adminNotes,
    this.paymentNotes,
    this.isActive = true,
    this.childName,
    this.schoolName,
    this.cityName,
    this.districtName,
  });

  /// تحويل من JSON
  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      billId: json['bill_id'] as String,
      parentId: json['parent_id'] as String? ?? '',
      relatedRequestId: json['related_request_id'] as String?,
      billNumber: json['bill_number'] as String,
      billDescription: json['bill_description'] as String,
      amount: double.parse(json['amount'].toString()),
      paidAmount: double.parse(json['paid_amount']?.toString() ?? '0'),
      bankId: json['bank_id'] as String?,
      bankName: json['bank_name'] as String?,
      transferNumber: json['transfer_number'] as String?,
      receiptImagePath: json['receipt_image_path'] as String?,
      status: json['status'] as String,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      adminNotes: json['admin_notes'] as String?,
      paymentNotes: json['payment_notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      childName: json['child_name'] as String?,
      schoolName: json['school_name'] as String?,
      cityName: json['city_name'] as String?,
      districtName: json['district_name'] as String?,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'bill_id': billId,
      'parent_id': parentId,
      'related_request_id': relatedRequestId,
      'bill_number': billNumber,
      'bill_description': billDescription,
      'amount': amount,
      'paid_amount': paidAmount,
      'bank_id': bankId,
      'transfer_number': transferNumber,
      'receipt_image_path': receiptImagePath,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'admin_notes': adminNotes,
      'payment_notes': paymentNotes,
      'is_active': isActive,
    };
  }

  /// تحويل من الكيان
  factory BillModel.fromEntity(Bill entity) {
    return BillModel(
      billId: entity.billId,
      parentId: entity.parentId,
      relatedRequestId: entity.relatedRequestId,
      billNumber: entity.billNumber,
      billDescription: entity.billDescription,
      amount: entity.amount,
      paidAmount: entity.paidAmount,
      bankId: entity.bankId,
      bankName: entity.bankName,
      transferNumber: entity.transferNumber,
      receiptImagePath: entity.receiptImagePath,
      status: entity.status.name,
      dueDate: entity.dueDate,
      paidAt: entity.paidAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      adminNotes: entity.adminNotes,
      paymentNotes: entity.paymentNotes,
      isActive: entity.isActive,
      childName: entity.childName,
      schoolName: entity.schoolName,
      cityName: entity.cityName,
      districtName: entity.districtName,
    );
  }

  /// تحويل إلى الكيان
  Bill toEntity() {
    return Bill(
      billId: billId,
      parentId: parentId,
      relatedRequestId: relatedRequestId,
      billNumber: billNumber,
      billDescription: billDescription,
      amount: amount,
      paidAmount: paidAmount,
      bankId: bankId,
      bankName: bankName,
      transferNumber: transferNumber,
      receiptImagePath: receiptImagePath,
      status: BillStatusExtension.fromString(status),
      dueDate: dueDate,
      paidAt: paidAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      adminNotes: adminNotes,
      paymentNotes: paymentNotes,
      isActive: isActive,
      childName: childName,
      schoolName: schoolName,
      cityName: cityName,
      districtName: districtName,
    );
  }
}
