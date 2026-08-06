class ChatClient {
  final String id;
  final String name;

  ChatClient({
    required this.id,
    required this.name,
  });

  factory ChatClient.fromMap(String id, Map<String, dynamic> map) {
    String name = map['name'] ?? map['firstName'] ?? '';
    if (name.isEmpty) {
      name = 'عميل ($id)'; // Fallback to "Client (ID)"
    }
    
    return ChatClient(
      id: id,
      name: name,
    );
  }
}
