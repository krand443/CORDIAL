import 'package:flutter/material.dart';
import '../screens/home_page.dart'; // ホーム画面ウィジェットを読み込む
import '../screens/profile_page.dart'; // プロフィールを読み込む

// 下部バーのウィジット
class UnderBar extends StatelessWidget {

  const UnderBar({super.key});

  //プロフィールを開く
  void _open_profile(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
        transitionDuration: Duration.zero, // アニメーションなし
        reverseTransitionDuration: Duration.zero, // 逆方向のアニメーションもなし
      ),
    );
  }

  void _open_home(BuildContext context)
  {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MyHomePage(title: 'ログイン成功後'),
        transitionDuration: Duration.zero, // アニメーションなし
        reverseTransitionDuration: Duration.zero, // 逆方向のアニメーションもなし
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        BottomAppBar(
          color: Colors.white38, // 透明感を出す
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, size: 45),
                  onPressed: () {
                    // ホームボタン押下時の処理
                    _open_home(context);
                  },
                ),
                const SizedBox(width: 48), // FABのスペース確保
                IconButton(
                  icon: const Icon(Icons.person, size: 45),
                  onPressed: () {
                    // プロフィールボタン押下時の処理
                    _open_profile(context);
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton(
            tooltip: '新しい投稿',
            onPressed: () {  },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
