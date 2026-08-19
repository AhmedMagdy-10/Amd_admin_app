import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      'senderId': FirebaseAuth.instance.currentUser?.uid ?? 'ADMIN-001',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Upload image to Imgbb and return the URL
  Future<String?> uploadImageToImgbb(File imageFile) async {
    try {
      final apiKey = '0bfdb6d0e96fbf92e1bfe5bf83e34544';
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return json['data']['url'];
      } else {
        print('Imgbb upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Imgbb upload error: $e');
      return null;
    }
  }

  /// Upload document to Firebase Storage and return the URL
  Future<String?> uploadDocumentToFirebase(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final ref = FirebaseStorage.instance.ref().child('chat_documents/${DateTime.now().millisecondsSinceEpoch}_$fileName');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Firebase Storage document upload error: $e');
      return null;
    }
  }
}
