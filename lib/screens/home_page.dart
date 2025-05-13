import 'package:flutter/material.dart';
import 'package:cordial/widgets/under_bar.dart';
import 'package:cordial/widgets/post_card.dart';

// アプリのホーム画面を表すStatefulWidget（状態を持つウィジェット）
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// 上記のStatefulWidgetに対応する状態クラス
class _HomePageState extends State<HomePage> {
  // 投稿データを格納するリスト（ダミーデータを3件初期化）
  final List<String> _posts = [
    "こんにちは！FlutterでTwitter風アプリ作ってます。",
    "この投稿はダミーデータです。\njkasdhjakhsjashassakaskjk",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
  ];

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
      body: Container(
        color: Colors.grey.shade300,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 0), // 上下に余白を0
          itemCount: _posts.length, // 投稿の数を指定（動的に変わる）
          itemBuilder: (context, index) {
            // 各投稿をカード形式で表示
            return PostCard(postId: _posts[index]);
          },
        ),
      ),
    );
  }
}
