import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'fcm_credentials.dart';

class FcmApiService {
  static const String _messagingScope =
      'https://www.googleapis.com/auth/firebase.messaging';

  /// Obtains OAuth2 access token using service account credentials.
  static Future<String> getAccessToken() async {
    final Map<String, dynamic> serviceAccountMap =
        jsonDecode(FcmCredentials.serviceAccountJson);
    final accountCredentials =
        ServiceAccountCredentials.fromJson(serviceAccountMap);

    final client = http.Client();
    try {
      final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
        accountCredentials,
        [_messagingScope],
        client,
      );
      return accessCredentials.accessToken.data;
    } finally {
      client.close();
    }
  }

  /// Sends a push notification directly to a specific FCM token.
  static Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    if (token.isEmpty) {
      print('FCM API: Token is empty. Skipping notification.');
      return;
    }

    try {
      final tokenValue = await getAccessToken();
      final projectId =
          jsonDecode(FcmCredentials.serviceAccountJson)['project_id'] ??
              'amd-app-bbd5c';

      final url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $tokenValue',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'android': {
              'notification': {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'sound': 'default',
              }
            },
            'apns': {
              'payload': {
                'aps': {
                  'category': 'FLUTTER_NOTIFICATION_CLICK',
                  'sound': 'default',
                }
              }
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        print('FCM API: ✅ Notification sent successfully.');
      } else {
        print(
            'FCM API: ❌ Failed. Code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('FCM API: Error sending notification: $e');
    }
  }

  /// Sends a notification to a user by looking up their FCM token in
  /// Firestore → users/{userId}
  /// Tries multiple field names: fcmToken, token, fcm_token, pushToken
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
  }) async {
    final String targetId =
        (userId.isEmpty || userId == 'default_client') ? '' : userId;

    if (targetId.isEmpty) {
      print('FCM API: ❌ No valid userId provided. Skipping notification.');
      return;
    }

    print('FCM API: Looking for FCM token → users/$targetId');

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetId)
          .get();

      if (!doc.exists || doc.data() == null) {
        print('FCM API: ❌ Document users/$targetId not found in Firestore.');
        return;
      }

      final data = doc.data()!;
      print('FCM API: Document fields found: ${data.keys.toList()}');

      // Try multiple common field names the customer app might use
      final fcmToken = (data['fcmToken'] ??
              data['token'] ??
              data['fcm_token'] ??
              data['pushToken'] ??
              data['deviceToken'] ??
              '')
          .toString();

      if (fcmToken.isEmpty) {
        print(
            'FCM API: ❌ No FCM token found for users/$targetId. '
            'Tried fields: fcmToken, token, fcm_token, pushToken, deviceToken. '
            'Document fields: ${data.keys.toList()}');
        return;
      }

      print('FCM API: ✅ Token found. Sending "$title" to $targetId...');
      await sendNotification(token: fcmToken, title: title, body: body);

      // Save notification to Firestore for in-app display
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(targetId)
            .collection('notifications')
            .add({
          'title': title,
          'body': body,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
        print('FCM API: ✅ Saved in-app notification to users/$targetId/notifications/');
      } catch (e) {
        print('FCM API: Error saving in-app notification to Firestore: $e');
      }
    } catch (e) {
      print('FCM API: Error sending to $targetId: $e');
    }
  }
}
