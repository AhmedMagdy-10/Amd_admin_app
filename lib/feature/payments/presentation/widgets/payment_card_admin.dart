import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/payment_model.dart';
import '../../logic/payments_cubit.dart';
import 'receipt_viewer_sheet.dart';

class PaymentCardAdmin extends StatelessWidget {
  final PaymentModel payment;
  const PaymentCardAdmin({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(payment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment number circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4499).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${payment.paymentNumber}',
                      style: const TextStyle(
                        color: Color(0xFF4A4499),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'ReadexPro',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + request ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.userName,
                        style: const TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2A2375),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الدفعة رقم ${payment.paymentNumber}',
                        style: TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusInfo.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    payment.statusLabel,
                    style: TextStyle(
                      fontFamily: 'ReadexPro',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusInfo.fg,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF0F0F5)),
          ),

          // ── Info row ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                _infoItem(
                  Icons.calendar_today_rounded,
                  'تاريخ الاستحقاق',
                  _formatDate(payment.dueDate),
                ),
                const SizedBox(width: 24),
                _infoItem(
                  Icons.attach_money_rounded,
                  'المبلغ المستحق',
                  'ر.س ${payment.amount.toStringAsFixed(0)}',
                  highlight: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Receipt action ────────────────────────────────────────────────────
          if (payment.status == 'under_review' || payment.status == 'approved')
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<PaymentsCubit>(),
                          child: ReceiptViewerSheet(payment: payment),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: payment.status == 'approved'
                        ? const Color(0xFF2ECA7D).withValues(alpha: 0.12)
                        : const Color(0xFF4A4499),
                    foregroundColor: payment.status == 'approved'
                        ? const Color(0xFF2ECA7D)
                        : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(
                    payment.status == 'approved'
                        ? Icons.verified_rounded
                        : Icons.attach_file_rounded,
                    size: 18,
                  ),
                  label: Text(
                    payment.status == 'approved'
                        ? 'تم الاعتماد — عرض الإيصال'
                        : 'عرض الإيصال واعتماده',
                    style: const TextStyle(
                      fontFamily: 'ReadexPro',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value,
      {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontFamily: 'ReadexPro',
                    fontSize: 11,
                    color: Colors.grey.shade500)),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'ReadexPro',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: highlight ? const Color(0xFF2A2375) : Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  _StatusInfo _statusInfo(String status) {
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
      default: // pending
        return _StatusInfo(
          bg: const Color(0xFFF0F0F5),
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
