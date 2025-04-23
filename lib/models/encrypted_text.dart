class EncryptedText {
  final String id;
  final String title;
  final String encryptedContent;
  final DateTime createdAt;
  final DateTime modifiedAt;

  EncryptedText({
    required this.id,
    required this.title,
    required this.encryptedContent,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory EncryptedText.fromJson(Map<String, dynamic> json) {
    return EncryptedText(
      id: json['id'],
      title: json['title'],
      encryptedContent: json['encryptedContent'],
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'encryptedContent': encryptedContent,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }
}
