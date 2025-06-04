import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/widgets/custom_appbar.dart';
import 'package:cordial/navigation/swipe_back_wrapper.dart';
import 'package:cordial/screens/login_page.dart';

// タイムラインから遷移できるメニュー
class TimelineMenu extends StatelessWidget {
  const TimelineMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // SwipeBackWrapperでスライドで前画面に戻る
    return SwipeBackWrapper(
      left: true,//左スワイプ
      child: Scaffold(
        extendBody: true,
        body: Container(
          color: Theme.of(context).colorScheme.surface,
          // 投稿とその返信
          child: CustomScrollView(
            // 投稿とその返信の位一覧
            slivers: [
              // オリジナルAppbarを追加
              const CustomAppbar(titleText: "メニュー"),

              // メニュー項目（例：リスト形式）
              SliverList(
                delegate: SliverChildListDelegate([
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("プロフィール"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("設定"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text("ログアウト"),
                    onTap: () async {
                      // Firebase のログアウト
                      await FirebaseAuth.instance.signOut();

                      // ログイン画面などに遷移（必要に応じて）
                      if (!context.mounted) {
                        return; // 安全チェック（ウィジェットが dispose されてないか）
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
