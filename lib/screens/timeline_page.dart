import 'package:flutter/material.dart';

import '../widgets/timeline_widget.dart';

// アプリのホーム画面を表すStatefulWidget（状態を持つウィジェット）
class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

// 上記のStatefulWidgetに対応する状態クラス
class _TimelinePageState extends State<TimelinePage> {
  // 画面を描画するbuildメソッド（Flutterフレームワークが呼び出す）
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // アプリ全体の構造を提供するウィジェット（AppBar・body・FABなど含む）
      appBar: AppBar(
        // テーマに基づいた色をAppBarに設定（ダーク・ライトテーマ対応）
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 画面タイトルを表示（MyHomePageのtitleプロパティから取得）
        title: const Text("タイムライン"),
      ),

      // 投稿一覧（縦スクロール可能なListViewで構成）
      body: const TimelineWidget(),
    );
  }
}
