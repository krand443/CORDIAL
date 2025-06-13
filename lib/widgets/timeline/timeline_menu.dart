import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/widgets/custom_appbar.dart';
import 'package:cordial/navigation/swipe_back_wrapper.dart';
import 'package:cordial/screens/login/login_page.dart';

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
                  const CustomAppbar(titleText: "メニュー"),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      ListTile(
                        leading: Icon(Icons.phone_android),
                        title: Text("テーマ:端末の設定"),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: Icon(Icons.logout,color: Colors.red),
                        title: Text("ログアウト"),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
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
