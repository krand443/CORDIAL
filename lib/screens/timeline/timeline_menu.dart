import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/widgets/custom_appbar.dart';
import 'package:cordial/screens/timeline/change_theme.dart';
import 'package:cordial/screens/login/login_page.dart';
import 'package:cordial/navigation/page_transitions.dart';
import 'package:cordial/screens/license_page.dart';

// タイムラインから操作できるメニュー
class TimelineMenu extends StatelessWidget {
  const TimelineMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Row(
        children: [
          // 左側：メニュー
          Expanded(
            flex: 2,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: CustomScrollView(
                slivers: [
                  const CustomAppbar(titleText: 'メニュー'),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 50),
                      // テーマカラーを設定する項目
                      Material(
                        color: Colors.transparent, // 背景色
                        child: ListTile(
                          leading: const Icon(Icons.color_lens_outlined),
                          title: const Text('テーマ設定'),
                          onTap: () {
                            PageTransitions.fromBottom(
                                targetWidget: const ChangeTheme(),
                                context: context);
                          },
                        ),
                      ),
                      Material(
                        color: Colors.transparent, // 背景色
                        child: ListTile(
                          leading: const Icon(Icons.text_snippet_outlined),
                          title: const Text('ライセンス'),
                          onTap: () {
                            MyLicenseDialog.show(context);
                          },
                        ),
                      ),
                      Material(
                        color: Colors.transparent, // 背景色
                        child: ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('ログアウト'),
                          onTap: () async {
                            if (!context.mounted) return;
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                                  (route) => false,
                            );
                          },
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),

          // 右側：透明な領域
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque, // 空のContainerでもタップを検知するため
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
