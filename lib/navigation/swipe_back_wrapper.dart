import 'package:flutter/material.dart';

//スワイプで前の画面に戻れるようにするラッパーウィジェット
class SwipeBackWrapper extends StatefulWidget {

  final Widget child;

  const SwipeBackWrapper({super.key, required this.child});

  @override
  SwipeBackWrapperState createState() => SwipeBackWrapperState();
}

class SwipeBackWrapperState extends State<SwipeBackWrapper> {

  double _dragOffset = 0.0; // ドラッグした距離を記録する変数
  bool _isClosing = false; // 画面を閉じるフラグ

  // ユーザーが指を動かすときに呼び出される処理
  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isClosing) return;
    setState(() {
      // ドラッグの移動量を記録
      _dragOffset += details.primaryDelta!;

      // 左に行かせないように、ドラッグ量が0より小さくならないようにする
      if (_dragOffset < 0) _dragOffset = 0;
    });
  }

  // ユーザーが指を離したときに呼ばれる処理
  void _handleDragEnd(DragEndDetails details) {
    // ドラッグした距離が100ピクセル以上なら、画面を閉じる処理を開始
    if (_dragOffset > 100) {
      setState(() => _isClosing = true); // 画面を閉じるフラグを立てる
      Navigator.of(context).pop(); // 現在の画面を閉じる
    } else {
      // 100ピクセル未満なら元の位置に戻す
      setState(() => _dragOffset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent, // 背景を透明にする
      // GestureDetectorでスライドアニメーションの部分のみ処理
      body: GestureDetector(
        // 水平ドラッグの更新を検知し、_handleDragUpdate を呼び出す
        onHorizontalDragUpdate: _handleDragUpdate,
        // 水平ドラッグが終了したときに呼ばれる処理
        onHorizontalDragEnd: _handleDragEnd,

        child: Stack(
          children: [
            // スライドアニメーションを適用する部分
            Transform.translate(
              offset: Offset(_dragOffset, 0), // ドラッグ量に応じてウィジェットを移動
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}