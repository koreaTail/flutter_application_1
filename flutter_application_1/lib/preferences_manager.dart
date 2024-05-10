import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesManager {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 날짜 별 좋아요 상태 저장
  static Future<bool> saveLikedStatus(String date, bool isLiked) async {
    return await _prefs!.setBool(date + '_liked', isLiked);
  }

  // 날짜 별 메모 저장
  static Future<bool> saveMemo(String date, String memo) async {
    return await _prefs!.setString(date + '_memo', memo);
  }

  // 날짜 별 좋아요 상태 로드
  static bool? loadLikedStatus(String date) {
    return _prefs!.getBool(date + '_liked');
  }

  // 날짜 별 메모 로드
  static String? loadMemo(String date) {
    return _prefs!.getString(date + '_memo');
  }

  // 모든 데이터를 로드하는 예시 (특정 키 패턴에 따라)
  static Map<String, dynamic> loadAllData(String keyPattern) {
    Map<String, dynamic> data = {};
    for (String key in _prefs!.getKeys()) {
      if (key.contains(keyPattern)) {
        data[key] = _prefs!.get(key);
      }
    }
    return data;
  }

  // 특정 데이터 삭제
  static Future<bool> removeData(String key) async {
    return await _prefs!.remove(key);
  }

  // 모든 데이터 삭제
  static Future<bool> clearAll() async {
    return await _prefs!.clear();
  }
}
