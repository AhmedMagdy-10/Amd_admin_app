import 'package:flutter/material.dart';
import '../../../../core/utils/app_text_styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/requests_cubit.dart';

import '../request_details_page.dart';

class RequestItemCard extends StatelessWidget {
  final String name;
  final String requestId;
  final String date;
  final String status;
  final int currentStep;

  const RequestItemCard({
    super.key,
    required this.name,
    required this.requestId,
    required this.date,
    required this.status,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final cubit = BlocProvider.of<RequestsCubit>(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: cubit,
              child: RequestDetailsPage(requestId: requestId, name: name),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.readexSemiBold20.copyWith(
                          color: const Color(0xFF2A2375),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              requestId,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.readexRegular12.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              date,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.readexRegular12.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Options Menu (...)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.more_horiz,
                    color: Color(0xFF2A2375),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Status Pill
            Builder(
              builder: (context) {
                Color dotColor = const Color(0xFFF2994A);
                Color textColor = const Color(0xFF2A2375);
                Color pillBgColor = Colors.grey.shade50;
                String statusArabic = status;

                if (status == 'approved' || status == 'eligibility_approved' || status == 'request_approved' || status == 'transfer_approved' || status == 'مقبول' || status == 'موافق عليه' || status == 'مكتملة' || status == 'مكتمل') {
                  dotColor = const Color(0xFF2ECA7D);
                  textColor = const Color(0xFF2ECA7D);
                  pillBgColor = const Color(0xFFE8FAF0);
                  statusArabic = 'مقبول';
                } else if (status == 'not approved' || status == 'مرفوض') {
                  dotColor = const Color(0xFFF44336);
                  textColor = const Color(0xFFF44336);
                  pillBgColor = const Color(0xFFFEECEB);
                  statusArabic = 'مرفوض';
                } else if (status == 'تقديم طلب' || status == 'تقديم الطلب' || status == 'request_pending' || status == 'request_pendding') {
                  dotColor = const Color(0xFF3F51B5);
                  textColor = const Color(0xFF3F51B5);
                  pillBgColor = const Color(0xFFE8EAF6);
                  statusArabic = 'تقديم الطلب';
                } else if (status == 'انتظار تسليم المبلغ' || status == 'transfer_pending') {
                  dotColor = const Color(0xFF00838F);
                  textColor = const Color(0xFF00838F);
                  pillBgColor = const Color(0xFFE0F7FA);
                  statusArabic = 'انتظار تسليم المبلغ';
                } else {
                  dotColor = const Color(0xFFF2994A);
                  textColor = const Color(0xFFF2994A);
                  pillBgColor = const Color(0xFFFFF4E5);
                  statusArabic = 'جاري المراجعة';
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: pillBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusArabic,
                        style: AppTextStyles.readexMedium12.copyWith(
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Stepper
            _buildStepper(),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Attachments Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.attach_file,
                        color: Color(0xFF2A2375),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'مرفقات',
                        style: AppTextStyles.readexMedium14.copyWith(
                          color: const Color(0xFF2A2375),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '3',
                        style: AppTextStyles.readexMedium14.copyWith(
                          color: const Color(0xFF2A2375),
                        ),
                      ),
                    ],
                  ),
                ),
                // View Details
                Row(
                  children: [
                    Text(
                      'عرض التفاصيل',
                      style: AppTextStyles.readexMedium14.copyWith(
                        color: const Color(0xFF2A2375),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF2A2375),
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Step 1: جاري المراجعة
            _buildStepItem(
              title: 'جاري المراجعة',
              number: '1',
              icon: Icons.access_time,
              isActive: currentStep >= 1,
              activeColor: const Color(0xFF7A6DFF),
              isFirst: true,
            ),
            _buildConnector(isActive: currentStep >= 2),
            // Step 2: تقديم الطلب
            _buildStepItem(
              title: 'تقديم طلب',
              number: '2',
              icon: Icons.receipt_long,
              isActive: currentStep >= 2,
              activeColor: const Color(0xFF7A6DFF),
            ),
            _buildConnector(isActive: currentStep >= 3),
            // Step 3: انتظار تسليم المبلغ
            _buildStepItem(
              title: 'انتظار تسليم المبلغ',
              number: '3',
              icon: Icons.hourglass_empty,
              isActive: currentStep >= 3,
              activeColor: const Color(0xFF7A6DFF),
            ),
            _buildConnector(isActive: currentStep >= 4),
            // Step 4: مكتملة (Always green in design)
            _buildStepItem(
              title: 'مكتملة',
              number: '4',
              icon: Icons.check,
              isActive: currentStep >= 4,
              activeColor: const Color(0xFF2ECA7D),
              isLast: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepItem({
    required String title,
    required String number,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    bool isFirst = false,
    bool isLast = false,
    bool forceGreen = false,
  }) {
    Color bgColor;
    Color iconCol;

    if (isActive) {
      bgColor = activeColor;
      iconCol = Colors.white;
    } else {
      bgColor = Colors.grey.shade200;
      iconCol = Colors.grey.shade500;
    }

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconCol, size: 20),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: AppTextStyles.readexMedium10.copyWith(color: Colors.black87),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            number,
            style: AppTextStyles.readexMedium12.copyWith(
              color: const Color(0xFF2A2375),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required bool isActive}) {
    return Expanded(
      flex: 3,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return FractionallySizedBox(
            widthFactor: value,
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 30), // Align with circles
              color: isActive ? const Color(0xFF7A6DFF) : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }
}
