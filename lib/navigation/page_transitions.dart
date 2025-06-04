// 画面遷移を行う関数を集めたクラス

import 'package:flutter/cupertino.dart';

class PageTransitions {

  // 右から画面を表示するアニメーション付き遷移
  static fromRight(Widget targetWidget,BuildContext context){
    _basicTransitions(targetWidget,context,const Offset(1.0, 0.0));
  }

  //左からでてくる
  static fromLeft(Widget targetWidget,BuildContext context){
    _basicTransitions(targetWidget,context,const Offset(-1.0, 0.0));
  }

  // 下から出てくる
  static fromBottom(Widget targetWidget,BuildContext context){
    _basicTransitions(targetWidget,context,const Offset(0.0, 1.0));
  }

  // 遷移の基本関数(ローカル)
  static _basicTransitions(Widget targetWidget,BuildContext context,Offset startPosition){
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
              begin: startPosition, // 右から登場
              end: Offset.zero,               // 画面中央へ
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

}