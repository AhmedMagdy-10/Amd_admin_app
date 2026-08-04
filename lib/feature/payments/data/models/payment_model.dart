import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents one monthly installment payment linked to a financing request.
class PaymentModel {
  final String id;           // Firestore doc ID
  final String requestId;    // Linked financing request doc ID
  final String collection;   // Source collection of the request
  final String userName;
  final int paymentNumber;   // 1, 2, 3 … N
  final double amount;       // Monthly instalment amount
  final DateTime dueDate;
  final String status;       // pending | under_review | approved | rejected
  final String? receiptUrl;  // Firebase Storage download URL
  final DateTime? uploadedAt;
  final DateTime? approvedAt;

  const PaymentModel({
    required this.id,
    required this.requestId,
    required this.collection,
    required this.userName,
    required this.paymentNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.receiptUrl,
    this.uploadedAt,
    this.approvedAt,
  });

  // ── Factory ──────────────────────────────────────────────────────────────────

  factory PaymentModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return PaymentModel(
      id:            docId,
      requestId:     data['requestId']?.toString() ?? '',
      collection:    data['collection']?.toString() ?? 'FinancingRequests',
      userName:      data['userName']?.toString() ?? 'بدون اسم',
      paymentNumber: (data['paymentNumber'] as num?)?.toInt() ?? 0,
      amount:        (data['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate:       _toDateTime(data['dueDate']) ?? DateTime.now(),
      status:        data['status']?.toString() ?? 'pending',
      receiptUrl:    data['receiptUrl']?.toString(),
      uploadedAt:    _toDateTime(data['uploadedAt']),
      approvedAt:    _toDateTime(data['approvedAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'requestId':     requestId,
    'collection':    collection,
    'userName':      userName,
    'paymentNumber': paymentNumber,
    'amount':        amount,
    'dueDate':       Timestamp.fromDate(dueDate),
    'status':        status,
    if (receiptUrl != null) 'receiptUrl': receiptUrl,
    if (uploadedAt != null) 'uploadedAt': Timestamp.fromDate(uploadedAt!),
    if (approvedAt != null) 'approvedAt': Timestamp.fromDate(approvedAt!),
  };

  // ── Arabic status label ───────────────────────────────────────────────────────

  String get statusLabel {
    switch (status) {
      case 'pending':      return 'مستحقة';
      case 'under_review': return 'قيد المراجعة';
      case 'approved':     return 'مسددة';
      case 'rejected':     return 'مرفوضة';
      default:             return status;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
