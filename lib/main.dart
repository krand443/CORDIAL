import 'package:cordial/screens/login/login_page.dart';
import 'package:cordial/screens/edit_profile_page.dart';
import 'package:cordial/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'function/database_read.dart';
import 'screens/root_page.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // インターネットに接続できているかを確認
  var connectivityResult = await (Connectivity().checkConnectivity());

  // 画面を縦向きに制限
  SystemChrome.setPreferredOrientations([
    // 縦向き
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      // ネットワーク接続あり
      runApp(const Main());
    } else {
      // ネットワーク接続なし
      runApp(const NotInterNet());
    }
  });
}

// アプリ全体のルートウィジェット
class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ライトテーマ
      theme: AppTheme.lightTheme,
      // ダークテーマ
      darkTheme: AppTheme.darkTheme,

      // themeMode: ThemeMode.system, // 端末の設定に自動追従
      themeMode: ThemeMode.light,

      // アプリ起動時に表示されるホーム画面
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // スプラッシュ画面などに書き換えても良い
            return const SizedBox();
          }

          // ユーザ登録がされてるなら直接HOMEへ行く
          if (snapshot.hasData) {
            return FutureBuilder<bool>(
              future: DatabaseRead.isUserName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // ロード中の画面
                  return Container(
                    color: Theme.of(context).scaffoldBackgroundColor, // ここで背景色を指定
                    child: const Center(
                      child: SizedBox(
                        height: 270,
                        width: 270,
                        child: RiveAnimation.asset(
                          'assets/animations/load_icon.riv',
                          animations: ['load'],
                        ),
                      ),
                    ),
                  );
                }

                // ユーザー名が存在するならそのままログイン
                if (snapshot.data == true) {
                  return const RootPage();
                } else {
                  // ユーザー名未登録ならプロフィール作成
                  return const EditProfilePage();
                }
              },
            );
          }
          // 全て該当しないならログインページへ行く
          return const LoginPage();
        },
      ),
    );
  }
}

// インターネット接続なし
class NotInterNet extends StatelessWidget {
  const NotInterNet({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // アプリ全体のテーマ設定
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        useMaterial3: true,
      ),
      // アプリ起動時に表示されるホーム画面
      // home: const LoginPage(),
      home: const Center(
        child: Text(
          'インターネット接続を確認してください。',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
