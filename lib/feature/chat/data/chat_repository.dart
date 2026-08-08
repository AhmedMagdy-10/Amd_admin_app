import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'chat_message.dart';
import 'chat_client.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  /// Upload image to Firebase Storage and return the URL
  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child('chat_images').child('$fileName.jpg');
      
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Firebase Storage upload failed: $e');
      return null;
    }
  }
}
