import 'package:cordial/screens/login_page.dart';
import 'package:cordial/screens/make_profile_page.dart';
import 'package:flutter/material.dart';
import 'function/database.dart';
import 'manager/main_page_MG.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //インターネットに接続できているかを確認
  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult.contains(ConnectivityResult.mobile) ||
      connectivityResult.contains(ConnectivityResult.wifi)) {
    // ネットワーク接続あり
    runApp(const MAIN());
  } else {
    // ネットワーク接続なし
    runApp(const NotInterNet());
  }
}

// アプリ全体のルートウィジェット
class MAIN extends StatelessWidget {
  const MAIN({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // アプリ全体のテーマ設定
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      // アプリ起動時に表示されるホーム画面
      //home: const LoginPage(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // スプラッシュ画面などに書き換えても良い
            return const SizedBox();
          }

          //ユーザ登録がされてるなら直接HOMEへ行く
          if (snapshot.hasData) {
            return FutureBuilder<bool>(
              future: Database.isUserName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  //ロード中の画面
                  return const Center(
                      child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    color: Colors.blue,
                  ));
                }

                //ユーザー名が存在するならそのままログイン
                if (snapshot.data == true) {
                  return const MainPage();
                } else {
                  // ユーザー名未登録ならプロフィール作成
                  return const MakeProfilePage();
                }
              },
            );
          }
          //ログインページ
          return const LoginPage();
        },
      ),
    );
  }
}

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
      //home: const LoginPage(),
      home: const Center(
        child: Text(
          "インターネット接続を確認してください。",
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
