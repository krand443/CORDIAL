import 'package:flutter/material.dart';

// 共通で使用するAppbar
class CustomAppbar extends StatelessWidget {
  // バーのタイトルを指定
  final String titleText;

  // コールバック関数定義用
  final VoidCallback? onTap;

  const CustomAppbar({super.key, required this.titleText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,// 戻るアイコンの非表示
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

      // 関数が渡されてないならハンバーガーメニューを表示しない
      leading: onTap != null
          ? IconButton(
              icon: Icon(Icons.menu,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: onTap,
            )
          : null,
    );
  }
}
