import 'package:flutter/material.dart';
import 'package:cordial/widgets/under_bar.dart';
import 'package:cordial/function/make_link_text.dart';

// アプリのホーム画面を表すStatefulWidget（状態を持つウィジェット）
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// 上記のStatefulWidgetに対応する状態クラス
class _MyHomePageState extends State<MyHomePage> {
  // 投稿データを格納するリスト（ダミーデータを3件初期化）
  final List<String> _posts = [
    "こんにちは！FlutterでTwitter風アプリ作ってます。",
    "この投稿はダミーデータです。\njkasdhjakhsjashassakaskjk",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
  ];

  // 投稿追加処理（FloatingActionButtonが押されたときに実行）
  void _addPost() {
    setState(() {
      // 投稿リストの先頭に新しい投稿を挿入（最新が上に来る）
      _posts.insert(0, "新しい投稿が追加されました！${DateTime.now()}");
      // setStateでUIを再描画させる
    });
  }


  // 画面を描画するbuildメソッド（Flutterフレームワークが呼び出す）
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // アプリ全体の構造を提供するウィジェット（AppBar・body・FABなど含む）
      appBar: AppBar(
        // テーマに基づいた色をAppBarに設定（ダーク・ライトテーマ対応）
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 画面タイトルを表示（MyHomePageのtitleプロパティから取得）
        title: Text(widget.title),
      ),

      // 投稿一覧（縦スクロール可能なListViewで構成）
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 0), // 上下に余白を0
        itemCount: _posts.length, // 投稿の数を指定（動的に変わる）
        itemBuilder: (context, index) {
          // 各投稿をカード形式で表示
          return Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: InkWell(
              onTap: () {
                // タップ時の処理（デバッグ出力）
                print("投稿タップ: ${_posts[index]}");
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // プロフィールアイコン
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://abs.twimg.com/sticky/default_profile_images/default_profile_400x400.png',
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ユーザー情報と投稿内容
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ユーザー名（仮で固定）
                          const Text(
                            'ユーザーname',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),

                          // 投稿内容
                          RichText(
                            text: makeLinkText(_posts[index]),
                          ),
                          // AIアイコン&返信
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IntrinsicWidth(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 250), // ← ここで最大幅を設定
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.star,
                                          size: 24,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _posts[index],
                                        softWrap: true,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // FABとBottomAppBarを合体させたウィジェットを配置
      bottomNavigationBar: SizedBox(
        height: 80, // Stackぶん余裕を持たせる
        child: UnderBar(),
      ),

      // 下部に表示されるBottomAppBar

    );
  }
}
