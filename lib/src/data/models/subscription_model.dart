class Subscription {
  final String? id;
  final String? user;
  final String? gatewayId;
  final String? entity;
  final int? amount;
  final int? amountPaid;
  final int? amountDue;
  final String? currency;
  final int? attempts;
  final String? receipt;
  final String? status;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiryDate;
  final int? v;

  Subscription({
    this.id,
    this.user,
    this.gatewayId,
    this.entity,
    this.amount,
    this.amountPaid,
    this.amountDue,
    this.currency,
    this.attempts,
    this.receipt,
    this.status,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.expiryDate,
    this.v,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'] as String?,
      user: json['user'] as String?,
      gatewayId: json['gatewayId'] as String?,
      entity: json['entity'] as String?,
      amount: json['amount'] as int?,
      amountPaid: json['amountPaid'] as int?,
      amountDue: json['amountDue'] as int?,
      currency: json['currency'] as String?,
      attempts: json['attempts'] as int?,
      receipt: json['receipt'] as String?,
      status: json['status'] as String?,
      category: json['category'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate']) : null,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'gatewayId': gatewayId,
      'entity': entity,
      'amount': amount,
      'amountPaid': amountPaid,
      'amountDue': amountDue,
      'currency': currency,
      'attempts': attempts,
      'receipt': receipt,
      'status': status,
      'category': category,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      '__v': v,
    };
  }

  Subscription copyWith({
    String? id,
    String? user,
    String? gatewayId,
    String? entity,
    int? amount,
    int? amountPaid,
    int? amountDue,
    String? currency,
    int? attempts,
    String? receipt,
    String? status,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiryDate,
    int? v,
  }) {
    return Subscription(
      id: id ?? this.id,
      user: user ?? this.user,
      gatewayId: gatewayId ?? this.gatewayId,
      entity: entity ?? this.entity,
      amount: amount ?? this.amount,
      amountPaid: amountPaid ?? this.amountPaid,
      amountDue: amountDue ?? this.amountDue,
      currency: currency ?? this.currency,
      attempts: attempts ?? this.attempts,
      receipt: receipt ?? this.receipt,
      status: status ?? this.status,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      v: v ?? this.v,
    );
  }
}
