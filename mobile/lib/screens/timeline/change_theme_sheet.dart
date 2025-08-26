import 'package:flutter/material.dart';
import 'package:cordial/provider/theme_model.dart';
import 'package:provider/provider.dart';

// showModalBottomSheet の中身だけを担当するウィジェット
class ChangeThemeSheet extends StatelessWidget {
  const ChangeThemeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeModelを監視（変更で再描画）
    final themeModel = context.watch<ThemeModel>();

    return Container(
      // 背景色と角丸の設定
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // 中身に合わせて高さを調整
          children: [
            const SizedBox(height: 20),

            // ライトモード
            ListTile(
              selected: themeModel.isLight(),
              leading: Icon(
                Icons.light_mode,
                color: themeModel.isLight()
                    ? Theme.of(context).colorScheme.tertiaryContainer
                    : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
              ),
              title: Text(
                'ライトモード',
                style: TextStyle(
                    color: themeModel.isLight()
                        ? Theme.of(context).colorScheme.tertiaryContainer
                        : Theme.of(context).colorScheme.onPrimary),
              ),
              onTap: () {
                themeModel.setLight();
                Navigator.pop(context);
              },
            ),

            // ダークモード
            ListTile(
              selected: themeModel.isDark(),
              leading: Icon(
                Icons.dark_mode,
                color: themeModel.isDark()
                    ? Theme.of(context).colorScheme.tertiaryContainer
                    : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
              ),
              title: Text(
                'ダークモード',
                style: TextStyle(
                    color: themeModel.isDark()
                        ? Theme.of(context).colorScheme.tertiaryContainer
                        : Theme.of(context).colorScheme.onPrimary),
              ),
              onTap: () {
                themeModel.setDark();
                Navigator.pop(context);
              },
            ),

            // 端末設定に合わせる
            ListTile(
              selected: themeModel.isTerminal(),
              leading: Icon(
                Icons.phone_android,
                color: themeModel.isTerminal()
                    ? Theme.of(context).colorScheme.tertiaryContainer
                    : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
              ),
              title: Text(
                '端末の設定に合わせる',
                style: TextStyle(
                    color: themeModel.isTerminal()
                        ? Theme.of(context).colorScheme.tertiaryContainer
                        : Theme.of(context).colorScheme.onPrimary),
              ),
              onTap: () {
                themeModel.setTerminal();
                Navigator.pop(context);
              },
            ),

            // キャンセル（閉じるだけ）
            ListTile(
              title: const Center(child: Text('キャンセル')),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
