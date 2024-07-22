class Document {
  final int id;
  final String name;
  final String uploadDate;
  final String status;
  final String originalContent;
  final String improvedContent;

  Document({
    required this.id,
    required this.name,
    required this.uploadDate,
    required this.status,
    required this.originalContent,
    required this.improvedContent,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      name: json['name'] ?? '',
      uploadDate: json['upload_date'] ?? '',
      status: json['status'],
      originalContent: json['original_content'] ?? '',
      improvedContent: json['improved_content'] ?? '',
    );
  }
}
