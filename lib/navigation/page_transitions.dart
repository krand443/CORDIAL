import 'package:flutter/cupertino.dart';
import 'package:cordial/navigation/swipe_back_wrapper.dart';

// 画面スライドで登場、スワイプで退場させるラッパークラス
class PageTransitions {

  // 右から画面を表示するアニメーション付き遷移
  static fromRight({required Widget targetWidget,required BuildContext context,VoidCallback? onClose,}){
    _basicTransitions(SwipeBackWrapper(onClose: onClose,direction: SwipeDirection.right,child: targetWidget,),context,const Offset(1.0, 0.0));
  }

  // 左からでてくる
  static fromLeft({required Widget targetWidget,required BuildContext context,VoidCallback? onClose,}){
    _basicTransitions(SwipeBackWrapper(onClose: onClose,direction: SwipeDirection.left,child: targetWidget,),context,const Offset(-1.0, 0.0));
  }

  // 上からでてくる
  static fromTop({required Widget targetWidget,required BuildContext context,VoidCallback? onClose,}){
    _basicTransitions(SwipeBackWrapper(onClose: onClose,direction: SwipeDirection.up,child: targetWidget,),context,const Offset(0.0, -1.0));
  }

  // 下からでてくる
  static fromBottom({required Widget targetWidget,required BuildContext context,VoidCallback? onClose,}){
    _basicTransitions(SwipeBackWrapper(onClose: onClose,direction: SwipeDirection.down,child: targetWidget,),context,const Offset(0.0, 1.0));
  }

  // 遷移の基本関数
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
              begin: startPosition, // 登場座標
              end: Offset.zero,// 画面中央へ
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

}