import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavIcon extends StatelessWidget {
  final String svgString;
  final Color color;
  final double size;

  const CustomNavIcon({
    Key? key,
    required this.svgString,
    required this.color,
    this.size = 28,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svgString,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      width: size,
      height: size,
    );
  }
}

class AppIcons {
  // 3 squares and a plus at the top right
  static const String dashboard = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
  <rect x="3" y="3" width="7.5" height="7.5" rx="2" />
  <rect x="3" y="13.5" width="7.5" height="7.5" rx="2" />
  <rect x="13.5" y="13.5" width="7.5" height="7.5" rx="2" />
  <path d="M17.25 3.5 V10.5 M13.75 7 H20.75" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  // Receipt/document with a rounded cutout at the top and lines
  static const String requests = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg">
  <path d="M7 2h10a3 3 0 0 1 3 3v14a3 3 0 0 1 -3 3H7a3 3 0 0 1 -3 -3V5a3 3 0 0 1 3 -3z" />
  <path d="M8 2c0 1.5.5 2.5 2 3h4c1.5-.5 2-1.5 2-3" />
  <line x1="8" y1="10" x2="16" y2="10" />
  <line x1="8" y1="14" x2="16" y2="14" />
  <line x1="8" y1="18" x2="16" y2="18" />
</svg>
''';

  // Stylized wallet
  static const String payments = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 6a2 2 0 0 1 2 -2h12a2 2 0 0 1 2 2v1H4z" />
  <path d="M4 7h16v11a2 2 0 0 1 -2 2H6a2 2 0 0 1 -2 -2z" />
  <path d="M17 11h3v4h-3a2 2 0 0 1 -2 -2v0a2 2 0 0 1 2 -2z" />
  <line x1="18.5" y1="13" x2="18.5" y2="13.01" stroke-width="2.5" />
</svg>
''';

  // Settings gear
  static const String settings = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="3" />
  <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z" />
</svg>
''';

  static const String todayPayments = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="10"/>
  <path d="M12 6v12"/>
  <path d="M15 8H9.5a2.5 2.5 0 0 0 0 5H14.5a2.5 2.5 0 0 1 0 5H9"/>
</svg>
''';

  static const String monthPayments = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg">
  <rect x="5" y="2" width="14" height="20" rx="2" ry="2"/>
  <path d="M12 18h.01"/>
  <path d="M9 6h6"/>
</svg>
''';

  static const String requestsReview = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg">
  <path d="M6 3h12"/>
  <path d="M6 21h12"/>
  <path d="M8 3l4 8l-4 8"/>
  <path d="M16 3l-4 8l4 8"/>
</svg>
''';

  static const String requestsNew = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg">
  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
  <path d="M14 2v6h6"/>
  <path d="M12 18v-6"/>
  <path d="M9 15h6"/>
</svg>
''';
}
