class ChatClient {
  final String id;
  final String name;

  ChatClient({
    required this.id,
    required this.name,
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
      name = 'عميل ($id)'; // Fallback to "Client (ID)"
    }
    
    return ChatClient(
      id: id,
      name: name,
    );
  }
}
