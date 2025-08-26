import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/widgets/custom_appbar.dart';
import 'package:cordial/screens/login/login_page.dart';
import 'package:cordial/screens/license_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'change_theme_sheet.dart';

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
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              // 背景を透明にして角丸を有効化
                              isScrollControlled: true,
                              builder: (context) => const ChangeThemeSheet(),
                            );
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
                          leading: const Icon(Icons.privacy_tip_outlined),
                          title: const Text('プライバシーポリシー'),
                          onTap: () {
                            _showConfirmDialog(
                                context,
                                'プライバシーポリシーのページへ移動しますか？(Webサイトに遷移します)',
                                'https://ruten-studio.sakura.ne.jp/cordial/privacypolicy');
                          },
                        ),
                      ),
                      Material(
                        color: Colors.transparent, // 背景色
                        child: ListTile(
                          leading: const Icon(Icons.person_off),
                          title: const Text('アカウント削除'),
                          onTap: () {
                            _showConfirmDialog(
                              context,
                              'アカウント削除用のページへ移動しますか？(Webサイトに遷移します)',
                              'https://ruten-studio.sakura.ne.jp/cordial/delete-account'
                            );
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
                            Navigator.of(context, rootNavigator: true)
                                .pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
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

  void _showConfirmDialog(BuildContext context, String text, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認'),
          content: Text(text),
          actions: [
            TextButton(
              child: Text(
                'はい',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiaryContainer),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
                _launchUrl(context, url); // URLを開く
              },
            ),
            TextButton(
              child: const Text(
                'キャンセル',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URLを開けませんでした')),
      );
    }
  }
}
