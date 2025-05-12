import 'dart:convert';
import 'package:http/http.dart' as http;

class UserAccessPermissions {
  bool sendNotification;
  bool postRequirement;
  bool addReward;
  bool addCertificate;
  bool addSocialmedia;
  DateTime updatedAt;

  UserAccessPermissions({
    required this.sendNotification,
    required this.postRequirement,
    required this.addReward,
    required this.addCertificate,
    required this.addSocialmedia,
    required this.updatedAt,
  });

  factory UserAccessPermissions.fromJson(Map<String, dynamic> json) {
    return UserAccessPermissions(
      sendNotification: json['sendNotification'] ?? false,
      postRequirement: json['postRequirement'] ?? false,
      addReward: json['addReward'] ?? false,
      addCertificate: json['addCertificate'] ?? false,
      addSocialmedia: json['addSocialmedia'] ?? false,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class UserAccessService {
  static UserAccessPermissions? _permissions;

  static Future<UserAccessPermissions> fetchUserAccess() async {
    if (_permissions != null) {
      return _permissions!;
    }

    final response = await http.get(
      Uri.parse('http://api.itccconnect.com/api/v1/userAccess'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        _permissions = UserAccessPermissions.fromJson(jsonResponse['data'][0]);
        return _permissions!;
      }
    }
    
    // Return default permissions (all false) if request fails
    return UserAccessPermissions(
      sendNotification: false,
      postRequirement: false,
      addReward: false,
      addCertificate: false,
      addSocialmedia: false,
      updatedAt: DateTime.now(),
    );
  }

  static Future<bool> canSendNotification() async {
    final permissions = await fetchUserAccess();
    return permissions.sendNotification;
  }

  static Future<bool> canPostRequirement() async {
    final permissions = await fetchUserAccess();
    return permissions.postRequirement;
  }

  static Future<bool> canAddReward() async {
    final permissions = await fetchUserAccess();
    return permissions.addReward;
  }

  static Future<bool> canAddCertificate() async {
    final permissions = await fetchUserAccess();
    return permissions.addCertificate;
  }

  static Future<bool> canAddSocialMedia() async {
    final permissions = await fetchUserAccess();
    return permissions.addSocialmedia;
  }
} 