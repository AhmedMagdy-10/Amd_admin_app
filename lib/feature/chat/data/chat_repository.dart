import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'chat_message.dart';
import 'chat_client.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Replace with your actual Imgbb API key
  final String _imgbbApiKey = 'YOUR_IMGBB_API_KEY_HERE';

  /// Fetch all users from Firestore users collection as ChatClients
  Stream<List<ChatClient>> getClientsStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatClient.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Listen to messages for a specific client.
  /// Path: chats/{clientId}/messages  ordered by timestamp ascending
  Stream<List<ChatMessage>> getMessagesStream(String clientId) {
    return _firestore
        .collection('chats')
        .doc(clientId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Send a message to a client.
  /// Writes to: chats/{clientId}/messages
  /// Structure (exact):
  /// {
  ///   "text": "...",
  ///   "imageUrl": null,
  ///   "senderId": "ADMIN-001",
  ///   "timestamp": FieldValue.serverTimestamp()
  /// }
  Future<void> sendMessage({
    required String clientId,
    required String text,
    String? imageUrl,
  }) async {
    await _firestore
        .collection('chats')
        .doc(clientId)
        .collection('messages')
        .add({
      'text': text,
      'imageUrl': imageUrl, // null when not an image
      'senderId': 'ADMIN-001', // Hardcoded until Auth is implemented
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Upload image to Imgbb and return the URL
  Future<String?> uploadImageToImgbb(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final uri = Uri.parse('https://api.imgbb.com/1/upload');
      final response = await http.post(uri, body: {
        'key': _imgbbApiKey,
        'image': base64Image,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'];
      } else {
        print('Imgbb upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Imgbb: $e');
      return null;
    }
  }
}
