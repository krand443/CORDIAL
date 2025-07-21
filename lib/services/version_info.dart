import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionInfo {
  static const String url = 'https://appcast.vercel.app/version.json';
  static late String minVersion;
  static late String recommendedVersion;
  static late String latestVersion;

  // バージョン情報を取得して内部に保持する
  static Future<bool> initialize() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      minVersion = data['min_version'] ?? '';
      recommendedVersion = data['recommended_version'] ?? '';
      latestVersion = data['latest_version'] ?? '';
      return true;
    } else {
      print('Failed to fetch version info: ${response.statusCode}');
      return false;
    }
  }

  // 現在のアプリバージョンを取得
  static Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  // 推奨アップデート
  static String getRecommendedVersion(){
    return recommendedVersion;
  }

  // 最低バージョン
  static String getMinVersion(){
    return minVersion;
  }

  // 最新バージョン
  static String getLatestVersion(){
    return latestVersion;
  }
}
