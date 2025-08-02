import 'package:flutter/material.dart';

// カラーテーマを返すクラス
class AppTheme {
  // ダークテーマ、ライトテーマ共通のカラーを入れる変数
  static ThemeData commonColors = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        tertiary: Colors.green,
        tertiaryContainer: Color.fromARGB(255, 0, 140, 0),
      ));

  // ライトテーマ用
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey[100],
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: Colors.white,
        onPrimary: Colors.black,
        primaryContainer: const Color.fromARGB(255, 250, 250, 250),
        onPrimaryContainer: Colors.black,
        secondary: const Color.fromARGB(255, 230, 230, 230),
        onSecondary: Colors.black,
        secondaryContainer: const Color.fromARGB(255, 230, 230,230),
        onSecondaryContainer: Colors.black,
        tertiary: commonColors.colorScheme.tertiary,
        onTertiary: Colors.black,
        tertiaryContainer: commonColors.colorScheme.tertiaryContainer,
        onTertiaryContainer: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        errorContainer: const Color.fromARGB(255, 255, 200, 200),
        onErrorContainer: Colors.black,
        surface: const Color.fromARGB(255, 240, 240, 240),
        onSurface: Colors.black,
        surfaceContainerHighest: const Color.fromARGB(255, 245, 245, 245),
        onSurfaceVariant: Colors.grey,
        outline: Colors.grey,
        outlineVariant: Colors.grey,
        shadow: Colors.black12,
        scrim: Colors.black54,
        inverseSurface: Colors.black,
        onInverseSurface: Colors.white,
        inversePrimary: Colors.black,
      ),

      // カーソルの色を追加
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black87, // カーソルを設定
        selectionHandleColor: Colors.grey, // 選択ハンドルの色
      ),

    );
  }

  // ダークテーマ用
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color.fromARGB(255, 20, 20, 20),
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: Colors.black,
        onPrimary: Colors.white,
        primaryContainer: const Color.fromARGB(255, 25,25, 25),
        onPrimaryContainer: Colors.white,
        secondary: const Color.fromARGB(255, 50, 50, 50),
        onSecondary: Colors.white,
        secondaryContainer: const Color.fromARGB(255, 50, 50, 50),
        onSecondaryContainer: Colors.white,
        tertiary: commonColors.colorScheme.tertiary,
        onTertiary: Colors.white,
        tertiaryContainer: commonColors.colorScheme.tertiaryContainer,
        onTertiaryContainer: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        errorContainer: const Color.fromARGB(255, 60, 0, 0),
        onErrorContainer: Colors.white,
        surface: const Color.fromARGB(255, 25, 25, 25),
        onSurface: Colors.white,
        surfaceContainerHighest: const Color.fromARGB(255, 25, 25, 25),
        onSurfaceVariant: Colors.grey,
        outline: Colors.grey,
        outlineVariant: Colors.grey,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Colors.white,
        onInverseSurface: Colors.black,
        inversePrimary: Colors.white,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color.fromARGB(255, 50, 50, 50),
      ),

      // カーソルの色を追加
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white, // カーソルを設定
        selectionHandleColor: Colors.grey, // 選択ハンドルの色
      ),
    );
  }
}
