import 'package:lockey_app/models/category.dart';
import 'package:lockey_app/services/encryption.dart';

class Password {

  const Password({
    this.id,
    required this.accountName,
    required this.password,
    this.site,
    this.category,
  });

  final int? id;
  final String accountName;
  final String password;
  final String? site;
  final Category? category;

  Future<Map<String, dynamic>> toJsonEncrypted() async {
    final encryptedPassword = await EncryptionService.encrypt(password);

    return {
      'id': id,
      'accountName': accountName,
      'password': encryptedPassword,
      if (site != null) 'site': site,
      if (category != null) 'category': category!.toJson(),
    };
  }

  static Future<Password> fromJsonEncrypted(Map<String, dynamic> json) async {
    final encryptedPassword = json['password'] as String;
    final decryptedPassword = await EncryptionService.decrypt(encryptedPassword);

    return Password(
      id: json['id'],
      accountName: json['accountName'],
      password: decryptedPassword,
      site: json.containsKey("site") ? json["site"] : null,
      category: json.containsKey("category")
          ? Category.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountName': accountName,
      'password': password,
      if (site != null) 'site': site,
      if (category != null) 'category': category,
    };
  }

  factory Password.fromJson(Map<String, dynamic> json) {
    return Password(
      id: json['id'],
      accountName: json['accountName'],
      password: json['password'],
      site: json.containsKey("site") ? json["site"] : null,
      category: json.containsKey("category")
          ? Category(
              colorCode: json['category']['colorCode'],
              name: json['category']['name'],
              id: json['category']['id'])
          : null,
    );
  }
}
