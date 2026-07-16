import 'package:flutter/material.dart';
import '../../../../core/utils/app_text_styles.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = [
      'الكل',
      'جاري المراجعه',
      'تقديم الطلب',
      'انتظار تسليم المبلغ',
      'متكملة',
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: filters.asMap().entries.map((entry) {
            final index = entry.key;
            final title = entry.value;
            final isActive = index == 0; // 'الكل' is active by default in UI

            return Padding(
              padding: const EdgeInsets.only(left: 8.0), // Space between chips
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF2A2375) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF2A2375)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  title,
                  style: AppTextStyles.readexMedium14.copyWith(
                    color: isActive ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
