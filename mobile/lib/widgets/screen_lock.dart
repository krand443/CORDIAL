import 'package:flutter/material.dart';

// バリアの表示状態を管理するコントローラー。
class ScreenLockController extends ChangeNotifier {
  bool _visible = false;

  bool get isVisible => _visible;

  void show() {
    _visible = true;
    notifyListeners();
  }

  void hide() {
    _visible = false;
    notifyListeners();
  }

  void toggle() {
    _visible = !_visible;
    notifyListeners();
  }
}

// タップ操作を遮断する全画面バリアウィジェット。
class BarrierWidget extends StatelessWidget {
  final ScreenLockController controller;
  final Color color;
  final bool dismissible;
  final Widget? loadingIndicator;

  const BarrierWidget({
    super.key,
    required this.controller,
    this.color = const Color(0x88000000),
    this.dismissible = false,
    this.loadingIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isVisible) return const SizedBox.shrink();

        return Stack(
          children: [
            ModalBarrier(
              dismissible: dismissible,
              color: color,
            ),
            if (loadingIndicator != null)
              Center(child: loadingIndicator),
          ],
        );
      },
    );
  }
}
