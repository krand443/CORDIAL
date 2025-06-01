//画面遷移を行う関数を集めたクラス

import 'package:flutter/cupertino.dart';
import '../screens/post_page.dart';

class PageTransitions {

  //右から画面を表示するアニメーション付き遷移
  static fromRight(Widget targetWidget,BuildContext context){
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false, // 透明な背景にする
        transitionDuration: const Duration(milliseconds: 200), // アニメーションの時間を指定
        pageBuilder: (context, animation, secondaryAnimation) => targetWidget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // スライドインアニメーション
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), // 右から登場
              end: Offset.zero,               // 画面中央へ
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

}