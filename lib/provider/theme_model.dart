import 'package:flutter/material.dart';
import 'package:cordial/utils/app_preferences.dart';

enum AppThemeMode  {
  dark,
  light,
  terminal,
}

// どの階層のウィジェットからでもアプリのテーマカラーを変更できるようにする関数を置いておくクラス
class ThemeModel extends ChangeNotifier {

  // テーマを入れておく変数
  late AppThemeMode appThemeMode;

  // この Future が解決されたら初期化が完了したことを意味します。
  late Future<void> _initializationCompleter;
  // 初期化処理が完了したことを外部に通知するためのgetter
  Future<void> get initializationDone => _initializationCompleter;

  // 初期化
  ThemeModel(){
    _initializationCompleter = _initializeTheme();// 端末に保存されたデータを読み込み、挿入する
  }

  // 初期化処理を非同期で行うメソッド
  Future<void> _initializeTheme() async {
    await _loadAppThemeMode();
    notifyListeners(); // 初期ロード完了をUIに通知
  }

  // 特定のテーマになっているか確認するための関数
  bool isLight(){
    if(appThemeMode == AppThemeMode.light) {
      return true;
    }
    return false;
  }
  bool isDark(){
    if(appThemeMode == AppThemeMode.dark) {
      return true;
    }
    return false;
  }
  bool isTerminal(){
    if(appThemeMode == AppThemeMode.terminal) {
      return true;
    }
    return false;
  }

  // テーマ変更用関数
  void setLight() async{
    appThemeMode = AppThemeMode.light;
    _saveAppThemeMode();
    notifyListeners();
  }
  void setDark() async{
    appThemeMode = AppThemeMode.dark;
    _saveAppThemeMode();
    notifyListeners();
  }
  void setTerminal() async{
    appThemeMode = AppThemeMode.terminal;
    _saveAppThemeMode();
    notifyListeners();
  }

  // テーマをロードして変数を更新する
  Future _loadAppThemeMode() async {
    final String? savedData = AppPreferences.load(Variable.appThemeMode);// 保存された文字列を読み込む

    if (savedData == null) {
      appThemeMode = AppThemeMode.terminal;
    }

    // Stringからenumに変換
    appThemeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.name == savedData, // 列挙子の名前が保存された文字列と一致するかどうか
      orElse: () {
        return AppThemeMode.terminal; // デフォルト値
      },
    );
  }

  // 端末にテーマ情報を保存しておく
  void _saveAppThemeMode() async{
    // enumのnameプロパティを直接使う
    final String saveData = appThemeMode.name;

    try{
      await AppPreferences.save(Variable.appThemeMode, saveData);
    }
    catch(e){
      print('\x1B[31m$e\x1B[0m');
    }

  }
}
