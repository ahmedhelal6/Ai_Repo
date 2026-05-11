import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static const String _storageKey = 'userData';

  final String? gender;
  final int? age;
  final int? height;
  final int? weight;
  final String? goal;
  final String? email;
  final String? userName;
  final String? imagePath;

  const UserData({
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.goal,
    this.email,
    this.userName,
    this.imagePath,
  });

  UserData copyWith({
  String? gender,
  int? age,
  int? height,
  int? weight,
  String? goal,
  String? email,
  String? userName,
  String? imagePath,
  bool clearImagePath = false,
}) {
  return UserData(
    gender: gender ?? this.gender,
    age: age ?? this.age,
    height: height ?? this.height,
    weight: weight ?? this.weight,
    goal: goal ?? this.goal,
    email: email ?? this.email,
    userName: userName ?? this.userName,
    imagePath: clearImagePath ? null : imagePath ?? this.imagePath,
  );
}

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      gender: json['gender']?.toString(),
      age: _toInt(json['age']),
      height: _toInt(json['height']),
      weight: _toInt(json['weight']),
      goal: json['goal']?.toString(),
      email: json['email']?.toString(),
      userName: json['userName']?.toString() ?? json['username']?.toString(),
      imagePath: json['imagePath']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'goal': goal,
      'email': email,
      'userName': userName,
      'imagePath': imagePath,
    };
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(toJson()));
  }

  static Future<UserData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_storageKey);

    if (rawData == null || rawData.isEmpty) {
      return null;
    }

    final decodedData = jsonDecode(rawData);

    if (decodedData is! Map<String, dynamic>) {
      return null;
    }

    return UserData.fromJson(decodedData);
  }

 static Future<void> clear() async {
  final prefs = await SharedPreferences.getInstance();
  final oldUser = await load();

  if (oldUser?.imagePath != null) {
    final imageOnly = UserData(imagePath: oldUser!.imagePath);
    await prefs.setString(_storageKey, jsonEncode(imageOnly.toJson()));
  } else {
    await prefs.remove(_storageKey);
  }
}

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }
}