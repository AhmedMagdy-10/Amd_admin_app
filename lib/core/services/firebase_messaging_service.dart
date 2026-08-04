import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'fcm_api_service.dart';

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("FCM Background: Message received: ${message.messageId}");
}

class FirebaseMessagingService {
  // Singleton pattern
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();

  factory FirebaseMessagingService() {
    return _instance;
  }

  FirebaseMessagingService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initializes messaging permissions, registers FCM token, and sets up message listeners.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // 1. Request permissions
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('FCM: Permission status: ${settings.authorizationStatus}');

    // 2. Local Notifications Setup (for showing foreground banners)
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print("FCM: Notification tapped: ${details.payload}");
      },
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'amd_admin_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for request notifications.', // description
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // 3. Register Token in Firestore
    await _registerToken();

    // 4. Setup Listeners
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FCM Foreground: Message received: ${message.notification?.title}');
      
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              androidChannel.id,
              androidChannel.name,
              channelDescription: androidChannel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Registers Admin's FCM token in firestore admins collection.
  Future<void> _registerToken() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) {
        print('FCM: Failed to generate token.');
        return;
      }
      print('FCM Admin Token: $token');

      // Update all documents in admins collection if they exist, or create default
      final adminsSnap = await FirebaseFirestore.instance.collection('admins').get();
      if (adminsSnap.docs.isNotEmpty) {
        for (final doc in adminsSnap.docs) {
          await doc.reference.update({'fcmToken': token});
        }
        print('FCM: Saved token to existing admins.');
      } else {
        await FirebaseFirestore.instance.collection('admins').doc('admin_default').set({
          'fcmToken': token,
          'name': 'المدير العام',
        });
        print('FCM: Created default admin and saved token.');
      }
    } catch (e) {
      print('FCM: Error registering token: $e');
    }
  }

  /// Helper to get user/client ID from request document in case it is not directly in payment document
  Future<String?> getClientIdFromRequest(String requestId, String collection) async {
    try {
      final doc = await FirebaseFirestore.instance.collection(collection).doc(requestId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return data['userId']?.toString() ?? data['clientId']?.toString();
        }
      }
    } catch (e) {
      print('FCM: Error fetching client ID for request $requestId: $e');
    }
    return null;
  }

  /// Sends request accepted notification to client
  Future<void> sendAcceptNotification({required String clientId, required String requestId}) async {
    await FcmApiService.sendNotificationToUser(
      userId: clientId,
      title: '✅ تم قبول طلب التمويل',
      body: 'عزيزي العميل، تم قبول طلب التمويل رقم $requestId الخاص بك بنجاح وهو الآن بانتظار استكمال الخطوات.',
    );
  }

  /// Sends request refused notification to client
  Future<void> sendRefuseNotification({required String clientId, required String requestId}) async {
    await FcmApiService.sendNotificationToUser(
      userId: clientId,
      title: '❌ تم رفض طلب التمويل',
      body: 'عزيزي العميل، نأسف لإبلاغك بأنه قد تم رفض طلب التمويل رقم $requestId.',
    );
  }

  /// Sends payment approved notification to client
  Future<void> sendPaymentApprovedNotification({required String clientId, required int installmentNum}) async {
    await FcmApiService.sendNotificationToUser(
      userId: clientId,
      title: '✅ تم تأكيد سداد القسط',
      body: 'تم تأكيد استلام سداد القسط رقم $installmentNum بنجاح. شكراً لك.',
    );
  }

  /// Sends payment rejected notification to client
  Future<void> sendPaymentRejectedNotification({required String clientId, required int installmentNum}) async {
    await FcmApiService.sendNotificationToUser(
      userId: clientId,
      title: '❌ تم رفض إيصال السداد',
      body: 'عزيزي العميل، تم رفض إيصال السداد المرفوع للقسط رقم $installmentNum. يرجى مراجعته وإعادة الرفع.',
    );
  }
}
