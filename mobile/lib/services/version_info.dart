import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionInfo {
  static late String minVersion;
  static late String recommendedVersion;
  static late String latestVersion;

  // RemoteConfigからバージョン情報を取得
  static Future<bool> initialize() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      // 設定
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 3),
      ));

      // デフォルト値（フェッチ失敗時用）
      await remoteConfig.setDefaults(const {
        'min_version': '0.5.0',
        'recommended_version': '1.0.0',
        'latest_version': '1.0.0',
      });

      // サーバーから取得＆反映
      await remoteConfig.fetchAndActivate();

      // 値を取り出す
      minVersion = remoteConfig.getString('min_version');
      recommendedVersion = remoteConfig.getString('recommended_version');
      latestVersion = remoteConfig.getString('latest_version');

      return true;
    } catch (e) {
      print('Failed to fetch version info from Remote Config: $e');
      return false;
    }
  }

  // 現在のアプリバージョン
  static Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  // 推奨アップデート
  static String getRecommendedVersion() {
    return recommendedVersion;
  }

  // 最低バージョン
  static String getMinVersion() {
    return minVersion;
  }

  // 最新バージョン
  static String getLatestVersion() {
    return latestVersion;
  }
}
