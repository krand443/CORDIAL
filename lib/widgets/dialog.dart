import 'package:flutter/material.dart';

OverlayEntry? _dialogEntry;

void showCustomDialog({
  required BuildContext context,
  required Offset offset,
  String text = "決定",
  VoidCallback? onTap,
}) {
  _dialogEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        //透明な背景（タップで閉じる）
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _dialogEntry?.remove();
              _dialogEntry = null;
            },
            child: Container(
              color: Colors.transparent, // タップは検知するが見えない
            ),
          ),
        ),

        //カスタムダイアログ
        Positioned(
          //位置を調整
          left: offset.dx,
          top: offset.dy,
          child: Container(
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    //関数を実行し、閉じる
                    onTap?.call();
                    _dialogEntry?.remove();
                    _dialogEntry = null;
                  },
                  child: Text(text),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Overlay.of(context).insert(_dialogEntry!);
}
