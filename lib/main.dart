import 'package:flutter/material.dart';
import 'screens/home_page.dart'; // ホーム画面ウィジェットを読み込む
import 'screens/login_page.dart';
import 'screens/profile_page.dart';
import 'manager/main_page_MG.dart';

void main() {
  // Flutterアプリの実行開始地点
  runApp(const MyApp());
}

// アプリ全体のルートウィジェット
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter デモアプリ',
      theme: ThemeData(
        // アプリ全体のテーマ設定
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
        useMaterial3: true,
      ),
      // アプリ起動時に表示されるホーム画面
      home: const MainPage(),
    );
  }
}
