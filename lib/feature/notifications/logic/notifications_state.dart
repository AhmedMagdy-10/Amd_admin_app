import '../data/models/notification_model.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationsLoaded(this.notifications)
      : unreadCount = notifications.where((n) => !n.isRead).length;
}

class NotificationsError extends NotificationsState {
  final String error;
  NotificationsError(this.error);
}
