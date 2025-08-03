// lib/data/models/batch_bill_model.dart
import '../../domain/entities/batch_bill.dart';

/// نموذج الفاتورة المُجمعة للتعامل مع قاعدة البيانات
class BatchBillModel {
  final String batchBillId;
  final String parentId;
  final String batchNumber;
  final String batchDescription;
  final double totalAmount;
  final int individualBillsCount;
  final double paidAmount;
  final String? bankId;
  final String? bankName;
  final String? transferNumber;
  final String? receiptImagePath;
  final DateTime? paymentDate;
  final String status;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? adminNotes;
  final String? paymentNotes;
  final bool isActive;

  const BatchBillModel({
    required this.batchBillId,
    required this.parentId,
    required this.batchNumber,
    required this.batchDescription,
    required this.totalAmount,
    required this.individualBillsCount,
    this.paidAmount = 0.0,
    this.bankId,
    this.bankName,
    this.transferNumber,
    this.receiptImagePath,
    this.paymentDate,
    required this.status,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.adminNotes,
    this.paymentNotes,
    this.isActive = true,
  });

  /// تحويل من JSON
  factory BatchBillModel.fromJson(Map<String, dynamic> json) {
    return BatchBillModel(
      batchBillId: json['batch_bill_id'] as String,
      parentId: json['parent_id'] as String,
      batchNumber: json['batch_number'] as String,
      batchDescription: json['batch_description'] as String,
      totalAmount: double.parse(json['total_amount'].toString()),
      individualBillsCount: json['individual_bills_count'] as int,
      paidAmount: double.parse(json['paid_amount']?.toString() ?? '0'),
      bankId: json['bank_id'] as String?,
      bankName: json['bank_name'] as String?,
      transferNumber: json['transfer_number'] as String?,
      receiptImagePath: json['receipt_image_path'] as String?,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'] as String)
          : null,
      status: json['status'] as String,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      adminNotes: json['admin_notes'] as String?,
      paymentNotes: json['payment_notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'batch_bill_id': batchBillId,
      'parent_id': parentId,
      'batch_number': batchNumber,
      'batch_description': batchDescription,
      'total_amount': totalAmount,
      'individual_bills_count': individualBillsCount,
      'paid_amount': paidAmount,
      'bank_id': bankId,
      'transfer_number': transferNumber,
      'receipt_image_path': receiptImagePath,
      'payment_date': paymentDate?.toIso8601String(),
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'admin_notes': adminNotes,
      'payment_notes': paymentNotes,
      'is_active': isActive,
    };
  }

  /// تحويل من الكيان
  factory BatchBillModel.fromEntity(BatchBill entity) {
    return BatchBillModel(
      batchBillId: entity.batchBillId,
      parentId: entity.parentId,
      batchNumber: entity.batchNumber,
      batchDescription: entity.batchDescription,
      totalAmount: entity.totalAmount,
      individualBillsCount: entity.individualBillsCount,
      paidAmount: entity.paidAmount,
      bankId: entity.bankId,
      bankName: entity.bankName,
      transferNumber: entity.transferNumber,
      receiptImagePath: entity.receiptImagePath,
      paymentDate: entity.paymentDate,
      status: entity.status.name,
      dueDate: entity.dueDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      adminNotes: entity.adminNotes,
      paymentNotes: entity.paymentNotes,
      isActive: entity.isActive,
    );
  }

  /// تحويل إلى الكيان
  BatchBill toEntity() {
    return BatchBill(
      batchBillId: batchBillId,
      parentId: parentId,
      batchNumber: batchNumber,
      batchDescription: batchDescription,
      totalAmount: totalAmount,
      individualBillsCount: individualBillsCount,
      paidAmount: paidAmount,
      bankId: bankId,
      bankName: bankName,
      transferNumber: transferNumber,
      receiptImagePath: receiptImagePath,
      paymentDate: paymentDate,
      status: BatchBillStatusExtension.fromString(status),
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      adminNotes: adminNotes,
      paymentNotes: paymentNotes,
      isActive: isActive,
    );
  }
}
