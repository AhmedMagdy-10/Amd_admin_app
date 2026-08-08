import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/payment_model.dart';
import '../../logic/payments_cubit.dart';
import '../user_payments_details_page.dart';

class UserPaymentsGroup {
  final String userName;
  final String requestId;
  final String collection;
  final List<PaymentModel> payments;

  UserPaymentsGroup({
    required this.userName,
    required this.requestId,
    required this.collection,
    required this.payments,
  });

  /// aggregate status:
  /// - 'under_review': if at least one payment is under_review.
  /// - 'approved': if ALL payments are approved.
  /// - 'rejected': if at least one payment is rejected and none are under_review.
  /// - 'pending': otherwise.
  String get status {
    if (payments.isEmpty) return 'pending';
    if (payments.any((p) => p.status == 'under_review')) {
      return 'under_review';
    }
    if (payments.every((p) => p.status == 'approved')) {
      return 'approved';
    }
    if (payments.any((p) => p.status == 'rejected')) {
      return 'rejected';
    }
    return 'pending';
  }

  String get statusLabel {
    switch (status) {
      case 'under_review': return 'قيد المراجعة';
      case 'approved':     return 'مسددة بالكامل';
      case 'rejected':     return 'مرفوضة';
      default:             return 'مستحقة';
    }
  }

  double get totalAmount => payments.fold(0.0, (sum, p) => sum + p.amount);
  double get paidAmount => payments.where((p) => p.status == 'approved').fold(0.0, (sum, p) => sum + p.amount);
  int get paidCount => payments.where((p) => p.status == 'approved').length;
  int get totalCount => payments.length;

  static List<UserPaymentsGroup> groupPayments(List<PaymentModel> allPayments) {
    final Map<String, List<PaymentModel>> grouped = {};
    for (final p in allPayments) {
      final key = p.requestId.isNotEmpty ? p.requestId : p.userName;
      grouped.putIfAbsent(key, () => []).add(p);
    }

    return grouped.entries.map((e) {
      final paymentsList = e.value;
      paymentsList.sort((a, b) => a.paymentNumber.compareTo(b.paymentNumber));
      final first = paymentsList.first;
      return UserPaymentsGroup(
        userName: first.userName,
        requestId: first.requestId,
        collection: first.collection,
        payments: paymentsList,
      );
    }).toList();
  }

  static List<UserPaymentsGroup> filterGrouped(List<UserPaymentsGroup> groups, String filter) {
    if (filter == 'الكل') return groups;
    if (filter == 'قيد المراجعة') {
      return groups.where((g) => g.status == 'under_review').toList();
    }
    if (filter == 'مسددة') {
      return groups.where((g) => g.status == 'approved').toList();
    }
    if (filter == 'مرفوضة') {
      return groups.where((g) => g.status == 'rejected').toList();
    }
    return groups;
  }
}

class UserPaymentsGroupCard extends StatefulWidget {
  final UserPaymentsGroup group;
  const UserPaymentsGroupCard({super.key, required this.group});

  @override
  State<UserPaymentsGroupCard> createState() => _UserPaymentsGroupCardState();
}

class _UserPaymentsGroupCardState extends State<UserPaymentsGroupCard> {
  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    final statusInfo = _statusInfo(g.status);
    final progress = g.totalCount > 0 ? g.paidCount / g.totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header Row (Tap to expand) ──────────────────────────────────────
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserPaymentsDetailsPage(
                    group: widget.group,
                    cubit: context.read<PaymentsCubit>(),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Icon
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A4499).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF4A4499),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // User Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.userName,
                              style: const TextStyle(
                                fontFamily: 'ReadexPro',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2A2375),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'رقم الطلب: ${g.requestId.length > 8 ? g.requestId.substring(0, 8) : g.requestId}',
                              style: TextStyle(
                                fontFamily: 'ReadexPro',
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusInfo.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          g.statusLabel,
                          style: TextStyle(
                            fontFamily: 'ReadexPro',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusInfo.fg,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Progress Bar & Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الأقساط المسددة: ${g.paidCount} من ${g.totalCount}',
                        style: const TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7070A0),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A4499),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 1.0 ? const Color(0xFF2ECA7D) : const Color(0xFF4A4499),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Aggregated Financial Info
                  Row(
                    children: [
                      _financialItem('إجمالي التمويل', 'ر.س ${g.totalAmount.toStringAsFixed(0)}'),
                      const SizedBox(width: 24),
                      _financialItem('المبلغ المحصّل', 'ر.س ${g.paidAmount.toStringAsFixed(0)}', highlight: true),
                      const Spacer(),
                      // Navigation Arrow
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _financialItem(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'ReadexPro',
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'ReadexPro',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: highlight ? const Color(0xFF2ECA7D) : const Color(0xFF2A2375),
          ),
        ),
      ],
    );
  }



  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'under_review':
        return _StatusInfo(bg: const Color(0xFFFFF4E5), fg: const Color(0xFFFFB03A));
      case 'approved':
        return _StatusInfo(bg: const Color(0xFFE8FAF0), fg: const Color(0xFF2ECA7D));
      case 'rejected':
        return _StatusInfo(bg: const Color(0xFFFFEBEB), fg: const Color(0xFFFF6B6B));
      default:
        return _StatusInfo(bg: const Color(0xFFF0F0F5), fg: const Color(0xFF7070A0));
    }
  }
}

class _StatusInfo {
  final Color bg;
  final Color fg;
  const _StatusInfo({required this.bg, required this.fg});
}
