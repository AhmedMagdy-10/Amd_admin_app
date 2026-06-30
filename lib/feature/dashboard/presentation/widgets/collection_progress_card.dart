import 'package:amd_admin/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class CollectionProgressCard extends StatelessWidget {
  const CollectionProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نسبة التحصيل الإجمالية',
                      style: AppTextStyles.readexMedium14.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '1.2M',
                          style: AppTextStyles.readexMedium24.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            'المستهدف',
                            style: AppTextStyles.readexMedium12.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '68%',
                  style: AppTextStyles.readexMedium32.copyWith(
                    color: const Color(0xFF4A4499),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.68,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF4A4499),
              ),
            ),
            const SizedBox(height: 24),
            // Summary text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildAmountInfo(
                    title: 'المسدد',
                    amount: '816,000',
                    color: const Color(0xFF4A4499),
                  ),
                ),
                Expanded(
                  child: _buildAmountInfo(
                    title: 'المتبقي',
                    amount: '384,000',
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            // View all button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF4A4499),
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'عرض جميع القروض',
                      style: AppTextStyles.readexMedium14.copyWith(
                        color: const Color(0xFF4A4499),
                      ),
                    ),
                  ],
                ),
                // Overlapping Avatars
                SizedBox(
                  width: 70,
                  height: 28,
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        child: _buildAvatar('https://i.pravatar.cc/100?img=1'),
                      ),
                      Positioned(
                        right: 20,
                        child: _buildAvatar('https://i.pravatar.cc/100?img=2'),
                      ),
                      Positioned(
                        right: 40,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFF4A4499),
                          child: Text(
                            '+12',
                            style: AppTextStyles.readexMedium12.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInfo({
    required String title,
    required String amount,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: AppTextStyles.readexMedium12.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    Text(
                      amount,
                      style: AppTextStyles.readexSemiBold20.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ر.س',
                      style: AppTextStyles.readexRegular12.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.grey.shade300,
        // Using icon as placeholder since NetworkImage might fail without internet/setup
        child: const Icon(Icons.person, size: 16, color: Colors.grey),
      ),
    );
  }
}
