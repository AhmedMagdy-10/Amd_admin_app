import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final String? imageUrl;
  final String senderId;
  final DateTime? timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.senderId,
    this.timestamp,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parsedTime;
    final ts = map['timestamp'];
    if (ts != null) {
      if (ts is Timestamp) {
        parsedTime = ts.toDate();
      } else if (ts is String) {
        parsedTime = DateTime.tryParse(ts);
      } else if (ts is int) {
        parsedTime = DateTime.fromMillisecondsSinceEpoch(ts);
      }
    }

    return ChatMessage(
      id: id,
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      senderId: map['senderId'] ?? '',
      timestamp: parsedTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imageUrl': imageUrl,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
