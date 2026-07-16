import 'package:amd_admin/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String name;
  final String role;
  final Color textColor;
  final Color subtitleColor;
  final Color iconColor;
  final Color iconBgColor;
  final int notificationCount;

  const CustomHeader({
    Key? key,
    required this.name,
    required this.role,
    required this.textColor,
    required this.subtitleColor,
    required this.iconColor,
    required this.iconBgColor,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Profile Info (First child -> goes to the Right in RTL)
          Expanded(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/100?img=11',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          name,
                          style: AppTextStyles.readexSemiBold20.copyWith(
                            color: textColor,
                          ),
                        ),
                      ),
                      Text(
                        role,
                        style: AppTextStyles.readexRegular14.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Notification Icon (Second child -> goes to the Left in RTL)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: iconColor,
                  size: 24,
                ),
              ),
              if (notificationCount > 0)
                Positioned(
                  top: -4,
                  right: -4, // Right in standard layout, will be adjusted for RTL visually or kept here
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A4499), // Or any highlight color, usually Red or Primary. The design has dark blue
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationCount > 9 ? '+9' : notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
