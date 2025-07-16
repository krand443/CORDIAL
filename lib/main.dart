import 'package:cordial/provider/theme_model.dart';
import 'package:cordial/screens/login/login_page.dart';
import 'package:cordial/screens/edit_profile_page.dart';
import 'package:cordial/screens/license_page.dart';
import 'package:cordial/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:cordial/moduls/upgrader.dart';
import 'services/database_read.dart';
import 'screens/root_page.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ThemeModelの初期化が完了するまで待つ
  final themeModelInstance = ThemeModel(); // ここでインスタンスを作成
  await themeModelInstance.initializationDone; // 初期化が完了するまで待機

  // ライセンスをセットする
  MyLicenseDialog.addCustomLicense();

  // 画面を縦向きに制限
  SystemChrome.setPreferredOrientations([
    // 縦向き
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      // ThemeModelをアプリケーションのルートで提供
      ChangeNotifierProvider.value(
        value: themeModelInstance,
        child: const Main(),
      ),
    );
  });
}

// アプリ全体のルートウィジェット
class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    // 現在のテーマモードを返す
    ThemeMode currentThemeMode() {
      if (themeModel.isLight()) return ThemeMode.light;
      if (themeModel.isDark()) return ThemeMode.dark;
      if (themeModel.isTerminal()) return ThemeMode.system; // 端末のシステム設定に自動追従

      // 全て該当しないなら端末の設定に合わせる
      return ThemeMode.system;
    }

    // ThemeModelの変更を監視し、その変更があったときに自動的にUIを再構築
    return MaterialApp(
      // ライトテーマ
      theme: AppTheme.lightTheme,
      // ダークテーマ
      darkTheme: AppTheme.darkTheme,
      // テーマを設定
      themeMode: currentThemeMode(),

      // アプリ起動時に表示されるホーム画面
      home: UpgradeAlert(
        // ここにUpgradeAlertウィジェットを追加
        upgrader: Upgrader(
          debugDisplayAlways: true, // 開発中の確認用
          languageCode: 'ja',
          minAppVersion: '1.0.0', // 実際のバージョンより常に高く設定
        ),
        child: StreamBuilder<List<ConnectivityResult>>(
          // Connectivity().onConnectivityChanged ストリームを監視
          stream: Connectivity().onConnectivityChanged,
          builder: (context, connectivitySnapshot) {
            // 接続状態の確認中
            if (connectivitySnapshot.connectionState ==
                    ConnectionState.waiting ||
                !connectivitySnapshot.hasData) {
              return _loadAnimation(context);
            }

            final connectivityResult = connectivitySnapshot.data!;

            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, authSnapshot) {
                if (authSnapshot.connectionState == ConnectionState.waiting) {
                  // 認証状態の確認中
                  return _loadAnimation(context);
                }

                // ユーザがログインしている場合
                if (authSnapshot.hasData) {
                  return FutureBuilder<bool>(
                    future: DatabaseRead.isUserName(),
                    builder: (context, userNameSnapshot) {
                      if (userNameSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        // ユーザー名の確認中
                        return _loadAnimation(context);
                      }

                      // ユーザー名が存在するならそのままログイン
                      if (userNameSnapshot.data == true) {
                        return const RootPage();
                      } else {
                        // インターネット接続があるか確認
                        if (connectivityResult
                                .contains(ConnectivityResult.mobile) ||
                            connectivityResult
                                .contains(ConnectivityResult.wifi)) {
                          // ユーザー名未登録ならプロフィール作成
                          return const EditProfilePage();
                        } else {
                          // インターネット接続がない場合、NotInterNetウィジェットを表示
                          return const NotInterNet();
                        }
                      }
                    },
                  );
                }

                // インターネット接続があるか確認
                if (connectivityResult.contains(ConnectivityResult.mobile) ||
                    connectivityResult.contains(ConnectivityResult.wifi)) {
                  // 全て該当しないならログインページへ行く
                  return const LoginPage();
                } else {
                  // インターネット接続がない場合、NotInterNetウィジェットを表示
                  return const NotInterNet();
                }
              },
            );
          },
        ),
      ),
    );
  }
}

// クラゲが泳ぐアニメーションウィジェット
Widget _loadAnimation(BuildContext context){
  return Container(
    color: Theme.of(context).scaffoldBackgroundColor,
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

// インターネット接続なし
class NotInterNet extends StatelessWidget {
  const NotInterNet({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'インターネット接続を確認してください。\n※接続が確認でき次第自動で画面遷移します。',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
