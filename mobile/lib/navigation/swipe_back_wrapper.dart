import 'package:flutter/material.dart';

// 方向を指定する列挙型
enum SwipeDirection {
  left,   // 右から左へスワイプ
  right,  // 左から右へスワイプ
  up,     // 下から上へスワイプ
  down,   // 上から下へスワイプ
}

// 方向とWidgetを受け取ってスワイプで画面を閉じることができるクラス
class SwipeBackWrapper extends StatefulWidget {
  final Widget child;
  final SwipeDirection direction;
  final VoidCallback? onClose;// 閉じたときに呼ばれる関数

  const SwipeBackWrapper({
    super.key,
    required this.child,
    required this.direction,
    this.onClose,
  });

  @override
  State<SwipeBackWrapper> createState() => _SwipeBackWrapperState();
}

class _SwipeBackWrapperState extends State<SwipeBackWrapper> {
  Offset _dragOffset = Offset.zero; // スワイプされた距離
  bool _isClosing = false; // すでに閉じようとしているかのフラグ
  static const _threshold = 100.0; // この距離を超えたら画面を閉じる

  bool get _isHorizontal =>
      widget.direction == SwipeDirection.left || widget.direction == SwipeDirection.right;

  // スワイプを始めた時
  void _onDragUpdate(DragUpdateDetails d) {
    if (_isClosing) return;

    // スワイプに追従
    setState(() {
      switch (widget.direction) {
        case SwipeDirection.left:
          _dragOffset += Offset(d.delta.dx, 0);

          // 右側にはみ出ないようにする
          if(_dragOffset.dx > 0) {
            _dragOffset = const Offset(0, 0);
          }
          break;
        case SwipeDirection.right:
          _dragOffset += Offset(d.delta.dx, 0);

          // 左側にはみ出ないようにする
          if(_dragOffset.dx < 0) {
            _dragOffset = const Offset(0, 0);
          }
          break;
        case SwipeDirection.up:
          _dragOffset += Offset(0, d.delta.dy);

          // 下側にはみ出ないようにする
          if(_dragOffset.dy > 0) {
            _dragOffset = const Offset(0, 0);
          }
          break;
        case SwipeDirection.down:
          _dragOffset += Offset(0, d.delta.dy);

          // 上側にはみ出ないようにする
          if(_dragOffset.dy < 0) {
            _dragOffset = const Offset(0, 0);
          }
          break;
      }
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final distance = _isHorizontal ? _dragOffset.dx.abs() : _dragOffset.dy.abs();
    if (distance > _threshold) {
      setState(() => _isClosing = true);
      widget.onClose?.call();
      Navigator.of(context).pop();
    } else {
      setState(() => _dragOffset = Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    Offset offset = Offset.zero;
    switch (widget.direction) {
      case SwipeDirection.left:
        offset = Offset(_dragOffset.dx, 0);
        break;
      case SwipeDirection.right:
        offset = Offset(_dragOffset.dx, 0);
        break;
      case SwipeDirection.up:
        offset = Offset(0, _dragOffset.dy);
        break;
      case SwipeDirection.down:
        offset = Offset(0, _dragOffset.dy);
        break;
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: _isHorizontal ? _onDragUpdate : null,
        onHorizontalDragEnd: _isHorizontal ? _onDragEnd : null,
        onVerticalDragUpdate: !_isHorizontal ? _onDragUpdate : null,
        onVerticalDragEnd: !_isHorizontal ? _onDragEnd : null,
        child: Transform.translate(
          offset: offset,
          child: widget.child,
        ),
      ),
    );
  }
}
