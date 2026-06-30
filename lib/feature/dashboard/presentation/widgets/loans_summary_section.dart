import 'package:amd_admin/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class LoansSummarySection extends StatelessWidget {
  const LoansSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'ملخص القروض',
            style: AppTextStyles.readexSemiBold20.copyWith(
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Donut Chart Card
          Container(
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
                    Text(
                      'القروض المدفوعة والغير المدفوعة',
                      style: AppTextStyles.readexMedium14.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'اخر 30 يوم',
                      style: AppTextStyles.readexRegular12.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Legend (First child -> Right in RTL)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem(
                            title: 'تم الدفع',
                            subtitle: '120 قرض',
                            color: const Color(0xFF4A4499),
                          ),
                          const SizedBox(height: 16),
                          _buildLegendItem(
                            title: 'لم يتم الدفع',
                            subtitle: '20 قرض',
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                    // Donut Chart (Second child -> Left in RTL)
                    SizedBox(
                      height: 110,
                      width: 110,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 10,
                            color: Colors.grey.shade200,
                          ),
                          const CircularProgressIndicator(
                            value: 0.75,
                            strokeWidth: 10,
                            backgroundColor: Colors.transparent,
                            color: Color(0xFF4A4499),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '75%',
                                  style: AppTextStyles.readexMedium32.copyWith(
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'نسبة السداد',
                                  style: AppTextStyles.readexRegular12.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 6,
            left: 8,
          ), 
          height: 10,
          width: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
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
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  style: AppTextStyles.readexMedium16.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
