import 'package:cordial/provider/theme_model.dart';
import 'package:cordial/screens/login/login_page.dart';
import 'package:cordial/screens/edit_profile_page.dart';
import 'package:cordial/screens/license_page.dart';
import 'package:cordial/app_theme.dart';
import 'package:cordial/screens/login/wait_mail_authentication.dart';
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
import 'package:cordial/services/version_info.dart';
import 'package:cordial/widgets/admob_widgets.dart';
import 'package:cordial/utils/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 端末変数管理クラスを初期化
  await AppPreferences.initialize();

  // ThemeModelの初期化が完了するまで待つ
  final themeModelInstance = ThemeModel(); // ここでインスタンスを作成
  await themeModelInstance.initializationDone; // 初期化が完了するまで待機

  // バージョン情報を得るクラスを初期化
  await VersionInfo.initialize();

  // 広告ウィジェットを初期化
  AdMob.initializeAdPool();

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
          debugDisplayAlways: false, // 開発中の確認用
          languageCode: 'ja',
          minAppVersion: VersionInfo.minVersion, // 最低バージョン(これを下回ると強制アップデート)
        ),
        child: FutureBuilder<User?>(
          future: Future.value(FirebaseAuth.instance.currentUser),
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

                  // メール認証を終えてないならログイン画面へ
                  if(FirebaseAuth.instance.currentUser!.emailVerified == false){
                    return const LoginPage();
                  }

                  // ユーザー名が存在するならそのままログイン
                  if (userNameSnapshot.data == true) {
                    return const RootPage();
                  } else {
                    // ユーザー名未登録ならプロフィール作成
                    return const EditProfilePage(
                      disableCloseIcon: true,
                    );
                  }
                },
              );
            }
            // 全て該当しないならログインページへ行く
            return const LoginPage();
          },
        ),
      ),
    );
  }
}

// クラゲが泳ぐアニメーションウィジェット
Widget _loadAnimation(BuildContext context) {
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