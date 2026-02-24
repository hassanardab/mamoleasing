class Account {
  final String id;
  final String name;
  final String type;

  Account({required this.id, required this.name, required this.type});

  factory Account.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Account(
      id: documentId,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
    };
  }
}
