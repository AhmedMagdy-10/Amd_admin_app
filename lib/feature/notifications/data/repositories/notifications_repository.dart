import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationsRepository {
  NotificationsRepository._();
  static final NotificationsRepository instance = NotificationsRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<List<NotificationModel>> _controller =
      StreamController<List<NotificationModel>>.broadcast();

  StreamSubscription<QuerySnapshot>? _sub;

  Stream<List<NotificationModel>> get stream => _controller.stream;

  void init() {
    _sub?.cancel();
    
    _sub = _firestore
        .collection('admins')
        .doc('ADMIN-001')
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snap) {
        final list = snap.docs
            .map((d) => NotificationModel.fromFirestore(d.id, d.data()))
            .toList();
        
        if (!_controller.isClosed) {
          _controller.add(list);
        }
      },
      onError: _controller.addError,
    );
  }

  Future<void> markAsRead(String id) async {
    try {
      await _firestore
          .collection('admins')
          .doc('ADMIN-001')
          .collection('notifications')
          .doc(id)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification $id as read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _firestore
          .collection('admins')
          .doc('ADMIN-001')
          .collection('notifications')
          .doc(id)
          .delete();
    } catch (e) {
      print('Error deleting notification $id: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final snap = await _firestore
          .collection('admins')
          .doc('ADMIN-001')
          .collection('notifications')
          .get();
      
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
