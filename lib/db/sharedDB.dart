import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  String long = "long";
  String lat = "lat";

  late SharedPreferences prefs;

  Future<SharedPreferences> getInstance() async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  void putString(String key, String value) async {
    prefs.setString(key, value);
  }

  String getString(String key, String defValue) {
    return prefs.getString(key) ?? defValue;
  }

  void putInt(String key, int value) {
    prefs.setInt(key, value);
  }

  int getInt(String key, int defValue) {
    return prefs.getInt(key) ?? defValue;
  }

  void putDouble(String key, double value) async {
    await getInstance();
    prefs.setDouble(key, value);
  }

  double getDouble(String key, double defValue) {
    return prefs.getDouble(key) ?? defValue;
  }

  void putBoolean(String key, bool value) {
    prefs.setBool(key, value);
  }

  bool getBoolean(String key, bool defValue) {
    return prefs.getBool(key) ?? defValue;
  }

  clear() {
    prefs.clear();
  }
}
