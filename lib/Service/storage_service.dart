import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static final SharedPrefHelper _instance = SharedPrefHelper._internal();
  factory SharedPrefHelper() => _instance;
  SharedPrefHelper._internal();

  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save a string value
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// Get a string value
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// Save an integer value
  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  /// Get an integer value
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// Save a boolean value
  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  /// Get a boolean value
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// Save a double value
  static Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  /// Get a double value
  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  /// Save a list of strings
  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  /// Get a list of strings
  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  /// Remove a specific key
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  /// Clear all preferences
  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
