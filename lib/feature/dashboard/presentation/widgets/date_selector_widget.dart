import 'package:amd_admin/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class DateSelectorWidget extends StatelessWidget {
  const DateSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Right Text and Icon (First child -> Right in RTL)
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تاريخ العرض',
                      style: AppTextStyles.readexRegular12.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'اليوم 24 اكتوبر 2026',
                      style: AppTextStyles.readexMedium16.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Left Button (Second child -> Left in RTL)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'تغيير التاريخ',
                style: AppTextStyles.readexMedium14.copyWith(
                  color: const Color(0xFF4A4499),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
