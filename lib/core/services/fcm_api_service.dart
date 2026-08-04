import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'fcm_credentials.dart';

class FcmApiService {
  static const String _messagingScope = 'https://www.googleapis.com/auth/firebase.messaging';

  /// Obtains OAuth2 access token using service account credentials.
  static Future<String> getAccessToken() async {
    final Map<String, dynamic> serviceAccountMap = jsonDecode(FcmCredentials.serviceAccountJson);
    final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountMap);
    
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

  /// Sends a push notification to a specific FCM token.
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
      final projectId = jsonDecode(FcmCredentials.serviceAccountJson)['project_id'] ?? 'amd-app-bbd5c';
      
      final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');
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
        print('FCM API: Notification sent successfully.');
      } else {
        print('FCM API: Failed to send. Code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('FCM API: Error sending notification: $e');
    }
  }

  /// Looks up user's FCM token from the users collection and sends them a notification.
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
  }) async {
    if (userId.isEmpty || userId == 'default_client') {
      print('FCM API: Invalid user ID. Skipping notification.');
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print('FCM API: User document $userId not found.');
        return;
      }

      final fcmToken = userDoc.data()?['fcmToken']?.toString();
      if (fcmToken == null || fcmToken.isEmpty) {
        print('FCM API: User $userId has no fcmToken registered.');
        return;
      }

      await sendNotification(
        token: fcmToken,
        title: title,
        body: body,
      );
    } catch (e) {
      print('FCM API: Error sending to user $userId: $e');
    }
  }
}
