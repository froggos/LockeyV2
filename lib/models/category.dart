class Category {
  Category({
    required this.colorCode,
    required this.name,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  final String id;
  final int colorCode;
  final String name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'colorCode': colorCode,
      'name': name,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      colorCode: json['colorCode'],
      name: json['name'],
      id: json['id'],
    );
  }
}
