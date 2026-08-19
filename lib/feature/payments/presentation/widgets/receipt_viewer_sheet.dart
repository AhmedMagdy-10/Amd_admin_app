import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/widgets/custom_toast.dart';
import '../../data/models/payment_model.dart';
import '../../logic/payments_cubit.dart';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
/// Full-screen receipt viewer shown when admin taps "عرض الإيصال".
class ReceiptViewerSheet extends StatelessWidget {
  final PaymentModel payment;
  const ReceiptViewerSheet({super.key, required this.payment});

  Future<void> _downloadReceipt(BuildContext context, String url) async {
    try {
      if (context.mounted) {
        showToast(text: "جاري تحميل الإيصال...", state: ToastStates.success);
      }
      var response = await http.get(Uri.parse(url));
      
      // Request permission using gal
      if (!await Gal.hasAccess()) {
        await Gal.requestAccess();
      }

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(response.bodyBytes);

      // Save to gallery
      await Gal.putImage(tempFile.path);
      
      if (context.mounted) {
        showToast(text: "تم حفظ الإيصال في المعرض بنجاح", state: ToastStates.success);
      }
    } catch (e) {
      if (context.mounted) {
        showToast(text: "حدث خطأ أثناء التحميل: $e", state: ToastStates.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top > 24 ? MediaQuery.of(context).padding.top : 36.0), // Padding to avoid status bar
            AppBar(
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
          actions: [
            if (payment.receiptUrl != null && payment.receiptUrl!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () => _downloadReceipt(context, payment.receiptUrl!),
                tooltip: 'تحميل الإيصال',
              ),
          ],
        ),
        // ── Image ──────────────────────────────────────────────────────────
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return InteractiveViewer(
                    panEnabled: true,
                    scaleEnabled: true,
                    constrained: false, // allow child to be taller than viewport
                    child: Container(
                      width: constraints.maxWidth,
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      alignment: Alignment.center,
                      child: payment.receiptUrl != null && payment.receiptUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: payment.receiptUrl!,
                              width: constraints.maxWidth,
                              fit: BoxFit.fitWidth,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF6A5ACD),
                                ),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.broken_image,
                                        size: 64, color: Colors.white30),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'تعذّر عرض الصورة داخل التطبيق',
                                      style: TextStyle(
                                          color: Colors.white54, fontSize: 14, fontFamily: 'ReadexPro'),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final url = Uri.tryParse(payment.receiptUrl ?? '');
                                        if (url != null && await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4A4499),
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.open_in_browser, size: 18),
                                      label: const Text('فتح في المتصفح', style: TextStyle(fontFamily: 'ReadexPro')),
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
                  );
                },
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
            if (payment.status != 'paid' && payment.status != 'approved')
              Builder(
                builder: (context) {
                  bool isLoading = false;
                  return StatefulBuilder(
                    builder: (context, setState) {
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
        ), // Column
      ), // Scaffold
    ); // Directionality
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
    showToast(
      text: message,
      state: isSuccess ? ToastStates.success : ToastStates.error,
    );
  }
}
