import 'package:amd_admin/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedSubtitle extends StatelessWidget {
  const AnimatedSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'خطوتك الأولى نحو مشروعك تبدأ من هنا',
      textAlign: TextAlign.center,
      style: AppTextStyles.readexSemiBold16.copyWith(color: const Color(0xFF555555)),
    )
    .animate(delay: 1000.ms)
    .slideY(begin: 1.5, end: 0.0, duration: 800.ms, curve: Curves.easeOutCubic)
    .fadeIn(duration: 600.ms);
  }
}
