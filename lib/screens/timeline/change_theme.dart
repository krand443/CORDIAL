import 'package:flutter/material.dart';
import 'package:cordial/provider/theme_model.dart';
import 'package:provider/provider.dart';

// テーマを選択するウィジェットを表示
class ChangeTheme extends StatefulWidget {
  const ChangeTheme({super.key});

  @override
  State<ChangeTheme> createState() => ChangeThemeState();
}

class ChangeThemeState extends State<ChangeTheme> {
  @override
  Widget build(BuildContext context) {
    // ThemeModelを取得
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque, // 空のContainerでもタップを検知するため
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2), // 背景色をここに移動
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28), // 左上
                topRight: Radius.circular(28), // 右上
              ), // 角丸の半径を指定
            ),
            child: SizedBox(
              child: Column(
                children: [
                  const SizedBox(
                    height: 22,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.light_mode,
                      color: themeModel.isLight() ? Colors.green : Colors.grey,
                    ),
                    title: const Text('ライトモード'),
                    onTap: () {
                      themeModel.setLight();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.dark_mode,
                      color: themeModel.isDark() ? Colors.green : Colors.grey,
                    ),
                    title: const Text('ダークモード'),
                    onTap: () {
                      themeModel.setDark();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.phone_android,
                      color:
                          themeModel.isTerminal() ? Colors.green : Colors.grey,
                    ),
                    title: const Text('端末の設定に合わせる'),
                    onTap: () {
                      themeModel.setTerminal();
                    },
                  ),
                  ListTile(
                    title: const Center(child: Text('キャンセル')),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
