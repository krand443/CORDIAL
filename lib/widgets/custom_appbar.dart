import 'package:flutter/material.dart';

// 共通で使用するAppbar
class CustomAppbar extends StatelessWidget {
  // バーのタイトルを指定
  final String titleText;

  // 先頭アイコン
  final Widget? leading;

  // 末尾アイコン
  final List<Widget>? actions;

  const CustomAppbar({super.key, required this.titleText,this.leading, this.actions});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      // 戻るアイコンの非表示
      surfaceTintColor: Colors.transparent,
      floating: true,
      snap: true,
      elevation: 0,
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0),
        ),
      ),
      title: Text(
        titleText,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),

      leading: leading,

      actions: actions,
    );
  }
}
