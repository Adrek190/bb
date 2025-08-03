class Invoice {
  final String invoiceId;
  final String? parentId;
  final double amount;
  final String status;
  final String? description;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.invoiceId,
    this.parentId,
    required this.amount,
    required this.status,
    this.description,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceId: json['invoice_id'] as String,
      parentId: json['parent_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      description: json['description'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'parent_id': parentId,
      'amount': amount,
      'status': status,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Invoice copyWith({
    String? invoiceId,
    String? parentId,
    double? amount,
    String? status,
    String? description,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      invoiceId: invoiceId ?? this.invoiceId,
      parentId: parentId ?? this.parentId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isOverdue =>
      dueDate != null && DateTime.now().isAfter(dueDate!) && !isPaid;

  @override
  String toString() {
    return 'Invoice(invoiceId: $invoiceId, amount: $amount, status: $status, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invoice && other.invoiceId == invoiceId;
  }

  @override
  int get hashCode => invoiceId.hashCode;
}
