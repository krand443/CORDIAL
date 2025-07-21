import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:navigator_scope/navigator_scope.dart';
import 'package:cordial/screens/timeline/timeline_page.dart';
import 'package:cordial/screens/profile/profile_page.dart';
import 'package:cordial/widgets/under_bar.dart';

// ログイン後の画面を管理するクラス。複数画面にここから遷移する
class RootPage extends StatefulWidget {
  const RootPage({super.key, this.selectTab = 0});

  final int selectTab;

  @override
  State<RootPage> createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  // 現在選択されているタブのインデックス（0: home, 1: profile）
  late int currentTab;

  @override
  void initState() {
    super.initState();
    currentTab = widget.selectTab; // ここで受け取る
  }

  // ナビゲーションバーに表示するタブの情報
  final tabs = const [
    NavigationDestination(
      icon: Icon(Icons.home),
      label: 'HOME', // タブのラベル
    ),
    NavigationDestination(
      icon: Icon(Icons.person),
      label: 'PROFILE', // タブのラベル
    ),
  ];

  // 各タブに対応する Navigator のキー
  // これにより、各タブが独立したナビゲーションスタックを持てるようになる。
  final navigatorKeys = [
    GlobalKey<NavigatorState>(debugLabel: 'HOME Tab'),
    GlobalKey<NavigatorState>(debugLabel: 'PROFILE Tab'),
  ];

  // 現在表示中のタブに対応する Navigatorを取得
  NavigatorState get currentNavigator =>
      navigatorKeys[currentTab].currentState!;

  // タブが選択されたときの処理
  void onTabSelected(int tab) {
    if (tab == currentTab && currentNavigator.canPop()) {
      // 同じタブが再度タップされた場合、
      // そのタブ内のルートスタックを一番上（最初の画面）まで戻す。
      currentNavigator.popUntil((route) => route.isFirst);
    } else {
      // 違うタブが選択されたら、そのタブに切り替える。
      setState(() => currentTab = tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // UnderBarを透過させるため
      // 下部バー
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        child: SafeArea(
          child: SizedBox(
            height: 40.0,
            child: UnderBar(currentIndex: currentTab, onTap: onTabSelected),
          ),
        ),
      ),

      // ボディ部に選択されたタブの内容（NavigatorScope）を表示
      body: NavigatorScope(
        currentDestination: currentTab, // どのタブが選ばれているかを通知
        destinationCount: tabs.length, // タブの総数（ここでは2つ：Search と Cart）
        destinationBuilder: (context, index) {
          // 各タブに NestedNavigator（内部専用ナビゲーター）を構築
          return NestedNavigator(
            navigatorKey: navigatorKeys[index], // 各タブ固有の navigatorKey を指定

            builder: (context) {
              switch (index) {
                case 0:
                  return const TimelinePage(); // タブ0のとき
                case 1:
                  return ProfilePage(
                    userId: FirebaseAuth.instance.currentUser!.uid,
                  ); // タブ1のとき
                default:
                  return const TimelinePage(); // 万が一
              }
            },
          );
        },
      ),
    );
  }
}
