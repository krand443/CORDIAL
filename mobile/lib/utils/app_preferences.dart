import 'package:shared_preferences/shared_preferences.dart';

// 特定の変数を示す
enum Variable {
  appThemeMode,
  selectedAi,
}

// 端末に保存しておく変数を管理するクラス
class AppPreferences{

  static SharedPreferences? prefs;

  // SharedPreferencesインスタンスを取得(初期化時に呼ぶ)
  static Future<void> initialize() async{
    prefs = await SharedPreferences.getInstance();
  }

  // データを読み込む
  static String? load(Variable variable){
    // インスタンスがなければreturn
    if(prefs == null) {
      print('AppPreferences:Not initialized');
      return null;
    }

    final String? savedData = prefs!.getString(variable.name);// 保存された文字列を読み込む

    return savedData;
  }

  // データを保存する
  static Future<void> save(Variable variable,String value) async{
    // インスタンスがなければ初期化
    prefs ?? await initialize();

    await prefs?.setString(variable.name, value);

  }

}