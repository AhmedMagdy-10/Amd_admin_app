import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime? timestamp;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.timestamp,
    required this.isRead,
  });

  factory NotificationModel.fromFirestore(String docId, Map<String, dynamic> data) {
    DateTime? parsedTime;
    if (data['timestamp'] is Timestamp) {
      parsedTime = (data['timestamp'] as Timestamp).toDate();
    } else if (data['timestamp'] is String) {
      parsedTime = DateTime.tryParse(data['timestamp']);
    }

    return NotificationModel(
      id: docId,
      title: data['title']?.toString() ?? '',
      body: data['body']?.toString() ?? '',
      timestamp: parsedTime,
      isRead: data['isRead'] == true,
    );
  }

  String get timeAgoArabic {
    if (timestamp == null) return 'غير معروف';
    final now = DateTime.now();
    final difference = now.difference(timestamp!);

    if (difference.inDays > 365) {
      return 'منذ ${difference.inDays ~/ 365} سنة';
    } else if (difference.inDays > 30) {
      return 'منذ ${difference.inDays ~/ 30} شهر';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'منذ لحظات';
    }
  }
}
