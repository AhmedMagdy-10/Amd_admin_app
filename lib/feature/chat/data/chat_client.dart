class ChatClient {
  final String id;
  final String name;
  final DateTime? lastMessageTime;

  ChatClient({
    required this.id,
    required this.name,
    this.lastMessageTime,
  });

  factory ChatClient.fromMap(String id, Map<String, dynamic> map) {
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
    );
  }

  ChatClient copyWith({DateTime? lastMessageTime}) {
    return ChatClient(
      id: id,
      name: name,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }
}
