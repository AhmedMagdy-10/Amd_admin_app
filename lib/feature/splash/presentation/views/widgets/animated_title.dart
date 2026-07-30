import 'package:amd_admin/core/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedTitle extends StatelessWidget {
  const AnimatedTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        Assets.imagesAmad,
        height: 70,
      )
      .animate(delay: 500.ms)
      .fadeIn(duration: 800.ms),
    );
  }
}
