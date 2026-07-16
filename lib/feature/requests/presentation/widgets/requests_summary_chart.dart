import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/utils/app_text_styles.dart';

class RequestsSummaryChart extends StatelessWidget {
  const RequestsSummaryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side (Totals and Legend)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي الطلبات',
                  style: AppTextStyles.readexMedium14.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '2,099',
                  style: AppTextStyles.readexMedium32.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2A2375), // Dark Blue
                    fontSize: 36, // Exceptionally large as in design
                  ),
                ),
                Text(
                  'طلب',
                  style: AppTextStyles.readexMedium14.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                // Legend Items
                _buildLegendItem(
                  title: 'تقديم طلب',
                  count: '930',
                  color: const Color(0xFF2A2375), // Dark Blue
                ),
                const SizedBox(height: 12),
                _buildLegendItem(
                  title: 'جاري المراجعة',
                  count: '319',
                  color: const Color(0xFF9EA3C1), // Greyish Blue
                ),
                const SizedBox(height: 12),
                _buildLegendItem(
                  title: 'انتظار تسليم المبلغ',
                  count: '850',
                  color: const Color(0xFF7A6DFF), // Light Purple
                ),
                const SizedBox(height: 12),
                _buildLegendItem(
                  title: 'مكتملة',
                  count: '0',
                  color: const Color(0xFF2ECA7D), // Green
                ),
              ],
            ),
          ),
          const SizedBox(width: 24), // Gap between text and chart
          // Right Side (Donut Chart)
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: DonutChartPainter(
                    segments: [
                      DonutSegment(value: 930, color: const Color(0xFF2A2375)), // تقديم طلب
                      DonutSegment(value: 850, color: const Color(0xFF7A6DFF)), // انتظار تسليم المبلغ
                      DonutSegment(value: 319, color: const Color(0xFF9EA3C1)), // جاري المراجعة
                      DonutSegment(value: 0, color: const Color(0xFF2ECA7D)),   // مكتملة
                    ],
                    strokeWidth: 16, // Thinner stroke to match design better
                  ),
                ),
                // Center Text
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '2,099',
                        style: AppTextStyles.readexSemiBold20.copyWith(
                          color: const Color(0xFF2A2375),
                        ),
                      ),
                      Text(
                        'طلبات',
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
      ),
    );
  }

  Widget _buildLegendItem({
    required String title,
    required String count,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.readexMedium12.copyWith(
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          count,
          style: AppTextStyles.readexMedium12.copyWith(color: Colors.black87),
        ),
      ],
    );
  }
}

class DonutSegment {
  final double value;
  final Color color;

  DonutSegment({required this.value, required this.color});
}

class DonutChartPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double strokeWidth;

  DonutChartPainter({required this.segments, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    double total = segments.fold(0, (sum, item) => sum + item.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2; // Start from top

    for (var segment in segments) {
      if (segment.value <= 0) continue;
      
      final sweepAngle = (segment.value / total) * 2 * math.pi;
      
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return true;
  }
}
