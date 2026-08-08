import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/payments_cubit.dart';
import 'widgets/user_payments_group_card.dart' show UserPaymentsGroup;
import 'widgets/receipt_viewer_sheet.dart';
import '../../../core/widgets/custom_header.dart';
import 'package:lottie/lottie.dart';

class UserPaymentsDetailsPage extends StatelessWidget {
  final UserPaymentsGroup group;
  final PaymentsCubit cubit; // We need to pass it or provide it

  const UserPaymentsDetailsPage({
    super.key,
    required this.group,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final displayedPayments = group.payments.where((p) {
      final hasReceipt = p.receiptUrl != null && p.receiptUrl!.isNotEmpty;
      return hasReceipt || p.status != 'pending';
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5FB),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              CustomHeader(
                name: group.userName,
                role: 'تفاصيل الدفعات',
                textColor: const Color(0xFF4A4499),
                subtitleColor: Colors.grey,
                iconColor: const Color(0xFF4A4499),
                iconBgColor: Colors.white,
                notificationCount: 0,
                onBackButtonPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),

              // List
              Expanded(
                child: displayedPayments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/lottie/No Item Found.json',
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد إيصالات مرفوعة بعد',
                              style: TextStyle(
                                fontFamily: 'ReadexPro',
                                color: Colors.grey.shade500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: displayedPayments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final p = displayedPayments[index];
                          final pStatusInfo = _installmentStatusInfo(p.status);

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: const Color(
                                            0xFF4A4499,
                                          ).withValues(alpha: 0.08),
                                          child: Text(
                                            '${p.paymentNumber}',
                                            style: const TextStyle(
                                              fontFamily: 'ReadexPro',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF4A4499),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'الدفعة رقم ${p.paymentNumber}',
                                          style: const TextStyle(
                                            fontFamily: 'ReadexPro',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2A2375),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Mini Status Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pStatusInfo.bg,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        p.statusLabel,
                                        style: TextStyle(
                                          fontFamily: 'ReadexPro',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: pStatusInfo.fg,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _installmentInfoItem(
                                      Icons.calendar_today_rounded,
                                      'تاريخ الاستحقاق',
                                      _formatDate(p.dueDate),
                                    ),
                                    _installmentInfoItem(
                                      Icons.attach_money_rounded,
                                      'المبلغ المطلوب',
                                      'ر.س ${p.amount.toStringAsFixed(0)}',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Action Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => BlocProvider.value(
                                          value: cubit,
                                          child: ReceiptViewerSheet(payment: p),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: p.status == 'approved'
                                          ? const Color(
                                              0xFF2ECA7D,
                                            ).withValues(alpha: 0.1)
                                          : const Color(
                                              0xFF4A4499,
                                            ).withValues(alpha: 0.08),
                                      foregroundColor: p.status == 'approved'
                                          ? const Color(0xFF2ECA7D)
                                          : const Color(0xFF4A4499),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: Icon(
                                      p.status == 'approved'
                                          ? Icons.verified_rounded
                                          : (p.receiptUrl != null &&
                                                    p.receiptUrl!.isNotEmpty
                                                ? Icons.attach_file_rounded
                                                : Icons.edit_note_rounded),
                                      size: 18,
                                    ),
                                    label: Text(
                                      p.status == 'approved'
                                          ? 'معتمد — عرض التفاصيل'
                                          : (p.receiptUrl != null &&
                                                    p.receiptUrl!.isNotEmpty
                                                ? 'مراجعة الإيصال واعتماده'
                                                : 'إدارة الدفعة (اعتماد/رفض)'),
                                      style: const TextStyle(
                                        fontFamily: 'ReadexPro',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _installmentInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  _StatusInfo _installmentStatusInfo(String status) {
    switch (status) {
      case 'under_review':
        return _StatusInfo(
          bg: const Color(0xFFFFF4E5),
          fg: const Color(0xFFFFB03A),
        );
      case 'approved':
        return _StatusInfo(
          bg: const Color(0xFFE8FAF0),
          fg: const Color(0xFF2ECA7D),
        );
      case 'rejected':
        return _StatusInfo(
          bg: const Color(0xFFFFEBEB),
          fg: const Color(0xFFFF6B6B),
        );
      default:
        return _StatusInfo(
          bg: const Color(0xFFF5F5FA),
          fg: const Color(0xFF9E9E9E),
        );
    }
  }
}

class _StatusInfo {
  final Color bg;
  final Color fg;
  const _StatusInfo({required this.bg, required this.fg});
}
