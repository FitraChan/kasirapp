import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'login.dart';

class LogoutHelper {
  static Future<void> logout() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    await localStorage.clear();

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
      (route) => false,
    );
  }
}
