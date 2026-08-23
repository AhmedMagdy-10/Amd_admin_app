class ChatClient {
  final String id;
  final String name;
  final DateTime? lastMessageTime;
  final String? requestNumber;

  ChatClient({
    required this.id,
    required this.name,
    this.lastMessageTime,
    this.requestNumber,
  });

  factory ChatClient.fromMap(String id, Map<String, dynamic> map, {String? reqNumber}) {
    final firstName = (map['firstName'] ?? map['first_name'] ?? '').toString().trim();
    final lastName = (map['lastName'] ?? map['last_name'] ?? '').toString().trim();

    String name = '';
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      name = '$firstName $lastName'.trim();
    } else {
      name = (map['name'] ?? map['fullName'] ?? map['clientName'] ?? '').toString().trim();
    }

    if (name.isEmpty) {
      name = 'عميل ($id)';
    }

    return ChatClient(
      id: id,
      name: name,
      requestNumber: reqNumber,
    );
  }

  ChatClient copyWith({DateTime? lastMessageTime, String? requestNumber}) {
    return ChatClient(
      id: id,
      name: name,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      requestNumber: requestNumber ?? this.requestNumber,
    );
  }
}
