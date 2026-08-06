import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/payment_model.dart';
import '../../logic/payments_cubit.dart';
import '../../logic/payments_state.dart';

/// Full-screen receipt viewer shown when admin taps "عرض الإيصال".
class ReceiptViewerSheet extends StatelessWidget {
  final PaymentModel payment;
  const ReceiptViewerSheet({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'إيصال الدفعة ${payment.paymentNumber}',
            style: const TextStyle(
              fontFamily: 'ReadexPro',
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // ── Image ──────────────────────────────────────────────────────────
            Expanded(
              child: InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                child: Center(
                  child: payment.receiptUrl != null
                      ? Image.network(
                          payment.receiptUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF6A5ACD),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.broken_image,
                                    size: 64, color: Colors.white30),
                                SizedBox(height: 12),
                                Text(
                                  'تعذّر تحميل الصورة',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const Center(
                          child: Text(
                            'لا يوجد إيصال مرفق',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        ),
                ),
              ),
            ),

            // ── Payment Info Strip ─────────────────────────────────────────────
            Container(
              color: const Color(0xFF1A1A2E),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoItem('العميل',    payment.userName),
                  _infoItem('المبلغ',    'ر.س ${payment.amount.toStringAsFixed(0)}'),
                  _infoItem('رقم الدفعة', '#${payment.paymentNumber}'),
                ],
              ),
            ),

            // ── Action Buttons ─────────────────────────────────────────────────
            if (payment.status == 'under_review' || payment.status == 'pending')
              StatefulBuilder(
                builder: (context, setState) {
                  bool isLoading = false;

                  return Container(
                    color: const Color(0xFF1A1A2E),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2ECA7D),
                            ),
                          )
                        : Row(
                            children: [
                              // Reject
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    setState(() => isLoading = true);
                                    await context
                                        .read<PaymentsCubit>()
                                        .rejectPayment(payment);
                                    if (context.mounted) {
                                      _showSnackBar(context, 'تم رفض الدفعة بنجاح', false);
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFFF6B6B),
                                    side: const BorderSide(
                                        color: Color(0xFFFF6B6B), width: 1.5),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.close_rounded,
                                      size: 18),
                                  label: const Text(
                                    'رفض',
                                    style: TextStyle(
                                      fontFamily: 'ReadexPro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Approve
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    setState(() => isLoading = true);
                                    await context
                                        .read<PaymentsCubit>()
                                        .approvePayment(payment);
                                    if (context.mounted) {
                                      _showSnackBar(context, 'تم اعتماد الدفعة بنجاح', true);
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2ECA7D),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.check_circle_outline,
                                      size: 18),
                                  label: Text(
                                    payment.receiptUrl != null
                                        ? 'اعتماد الإيصال'
                                        : 'اعتماد الدفعة يدوياً',
                                    style: const TextStyle(
                                      fontFamily: 'ReadexPro',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),

            if (payment.status == 'approved')
              Container(
                color: const Color(0xFF1A1A2E),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECA7D).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF2ECA7D), width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_rounded,
                          color: Color(0xFF2ECA7D), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'تم اعتماد هذا الإيصال',
                        style: TextStyle(
                          fontFamily: 'ReadexPro',
                          color: Color(0xFF2ECA7D),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white38, fontSize: 11, fontFamily: 'ReadexPro')),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'ReadexPro')),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'ReadexPro',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? const Color(0xFF2ECA7D) : const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
