import 'package:flutter/material.dart';

import '../screens/make_post_page.dart';

class UnderBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const UnderBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              padding: const EdgeInsets.only(left: 30,right: 30),
              icon: Icon(
                Icons.home,
                size: 40,
                color: currentIndex == 0 ? Colors.blue : Colors.black,
              ),
              onPressed: () => onTap(0),
            ),
            const SizedBox(width: 10.0),//中央余白
            IconButton(
              padding: const EdgeInsets.only(left: 30,right: 30),
              icon: Icon(
                Icons.person,
                size: 40,
                color: currentIndex == 1 ? Colors.blue : Colors.black,
              ),
              onPressed: () => onTap(1),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: FloatingActionButton(
            tooltip: '新しい投稿',
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false, // 透明な背景にする
                  transitionDuration: const Duration(milliseconds: 200), // アニメーションの時間を指定
                  pageBuilder: (context, animation, secondaryAnimation) => const MakePostPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    // スライドインアニメーション
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 1.0), // 下から登場
                        end: Offset.zero,               // 画面中央へ
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
