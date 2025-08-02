import 'package:flutter/cupertino.dart';
import 'package:cordial/navigation/swipe_back_wrapper.dart';
import 'package:flutter/material.dart';

// 画面スライドで登場、スワイプで退場させるラッパークラス
class PageTransitions {

  // 右から画面を表示するアニメーション付き遷移
  static Future<T?> fromRight<T>({
    bool onUnderBar = false,
    required Widget targetWidget,
    required BuildContext context,
    VoidCallback? onClose,
  }) {
    if(!onUnderBar){
      return _basicTransitions<T>(
        SwipeBackWrapper(
          onClose: onClose,
          direction: SwipeDirection.right,
          child: targetWidget,
        ),
        context,
        const Offset(1.0, 0.0),
      );
    }
    else{
      return _onUnderBarTransitions<T>(
        SwipeBackWrapper(
          onClose: onClose,
          direction: SwipeDirection.right,
          child: targetWidget,
        ),
        context,
        const Offset(1.0, 0.0),
      );
    }
  }

  // 左からでてくる
  static Future<T?> fromLeft<T>({
    bool onUnderBar = false,
    required Widget targetWidget,
    required BuildContext context,
    VoidCallback? onClose,
  }) {
    if(!onUnderBar){
      return _basicTransitions<T>(
        SwipeBackWrapper(
          onClose: onClose,
          direction: SwipeDirection.left,
          child: targetWidget,
        ),
        context,
        const Offset(-1.0, 0.0),
      );
    }
    else{
      return _onUnderBarTransitions<T>(
        SwipeBackWrapper(
          onClose: onClose,
          direction: SwipeDirection.left,
          child: targetWidget,
        ),
        context,
        const Offset(-1.0, 0.0),
      );
    }
  }

  // 上からでてくる
  static Future<T?> fromTop<T>({
    bool onUnderBar = false,
    required Widget targetWidget,
    required BuildContext context,
    VoidCallback? onClose,
  }) {
    if(!onUnderBar){
      return _basicTransitions<T>(
        SwipeBackWrapper(
          onClose: onClose,
          direction: SwipeDirection.up,
          child: targetWidget,
        ),
        context,
        const Offset(0.0, -1.0),
      );
    }
    else{
      return _onUnderBarTransitions<T>(
        SwipeBackWrapper(
          onClose: onClose,
          direction: SwipeDirection.up,
          child: targetWidget,
        ),
        context,
        const Offset(0.0, -1.0),
      );
    }
  }

  // 下からでてくる
  static Future<T?> fromBottom<T>({
    bool onUnderBar = false,
    required Widget targetWidget,
    required BuildContext context,
    VoidCallback? onClose,
  }) {
    if(!onUnderBar){
      return _basicTransitions<T>(
        SwipeBackWrapper(
          onClose: onClose,
          direction: SwipeDirection.down,
          child: targetWidget,
        ),
        context,
        const Offset(0.0, 1.0),
      );
    }
    else{
      return _onUnderBarTransitions<T>(
        SwipeBackWrapper(
          onClose: onClose,
          direction: SwipeDirection.down,
          child: targetWidget,
        ),
        context,
        const Offset(0.0, 1.0),
      );
    }
  }

  // 遷移の基本関数
  static Future<T?> _basicTransitions<T>(
      Widget targetWidget,
      BuildContext context,
      Offset startPosition,
      ) {
    return Navigator.push<T>(
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

  static Future<T?> _onUnderBarTransitions<T>(
      Widget targetWidget,
      BuildContext context,
      Offset startPosition,
      ) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true, // 外側タップで閉じる
      barrierLabel: "dismiss",
      barrierColor: Colors.transparent, // 背景透過
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => targetWidget,
      transitionBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: startPosition,
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

}
