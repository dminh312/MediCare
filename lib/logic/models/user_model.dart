import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String role;
  final String? photoURL;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final UserPreferences preferences;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.role = 'user',
    this.photoURL,
    required this.createdAt,
    required this.updatedAt,
    required this.preferences,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      role: data['role'] ?? 'user',
      photoURL: data['photoURL'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      preferences: UserPreferences.fromMap(data['preferences']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'role': role,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'preferences': preferences.toMap(),
    };
  }
}

class UserPreferences {
  final bool healthConnectEnabled;
  final int autoSyncInterval;
  final bool notificationsEnabled;

  UserPreferences({
    this.healthConnectEnabled = false,
    this.autoSyncInterval = 60,
    this.notificationsEnabled = true,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      healthConnectEnabled: map['healthConnectEnabled'] ?? false,
      autoSyncInterval: map['autoSyncInterval'] ?? 60,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'healthConnectEnabled': healthConnectEnabled,
      'autoSyncInterval': autoSyncInterval,
      'notificationsEnabled': notificationsEnabled,
    };
  }
}
