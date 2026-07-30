import 'package:amd_admin/core/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedLogo extends StatelessWidget {
  final bool scaleUp;
  final VoidCallback? onScaleComplete;

  const AnimatedLogo({super.key, required this.scaleUp, this.onScaleComplete});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: scaleUp ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 600),
      child: AnimatedScale(
        scale: scaleUp ? 3.0 : 1.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeIn,
        onEnd: () {
          if (scaleUp && onScaleComplete != null) {
            onScaleComplete!();
          }
        },
        child: Center(
          child: Image.asset(Assets.imagesAmadIcon, width: 240, height: 240)
              .animate()
              .slideX(
                begin: 1.5,
                end: 0.0,
                duration: 1000.ms,
                curve: Curves.easeOutBack,
              ),
        ),
      ),
    );
  }
}
