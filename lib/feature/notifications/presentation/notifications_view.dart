import 'package:amd_admin/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/notifications_cubit.dart';
import '../logic/notifications_state.dart';
import '../data/models/notification_model.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الإشعارات',
          style: AppTextStyles.readexSemiBold20.copyWith(color: const Color(0xFF33334D)),
        ),
        leading: const SizedBox.shrink(),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_forward_ios, color: Color(0xFF33334D), size: 16),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A4499)));
          }
          if (state is NotificationsError) {
            return Center(child: Text('حدث خطأ: ${state.error}'));
          }
          if (state is NotificationsLoaded) {
            final notifications = state.notifications;
            
            if (notifications.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد إشعارات',
                  style: AppTextStyles.readexMedium16.copyWith(color: Colors.grey),
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _NotificationCard(
                  notification: notif,
                  onTap: () {
                    if (!notif.isRead) {
                      context.read<NotificationsCubit>().markAsRead(notif.id);
                    }
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bell icon — FIRST in Row = appears on RIGHT side in RTL
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF3F4F9),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF6B65B5),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Text content — expands in the middle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title.trim(),
                    textAlign: TextAlign.start,
                    style: AppTextStyles.readexSemiBold14.copyWith(
                      color: const Color(0xFF1F1F39),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (notification.body.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body.trim(),
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.readexRegular12.copyWith(
                        color: const Color(0xFF9E9EAF),
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    notification.timeAgoArabic,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.readexRegular10.copyWith(
                      color: const Color(0xFFC4C4D4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Unread blue dot — LAST in Row = appears on LEFT side in RTL
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnread ? const Color(0xFF6B65B5) : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
