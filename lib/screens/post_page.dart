import 'package:flutter/material.dart';
import 'package:cordial/widgets/under_bar.dart';
import '../widgets/post_card.dart';

//投稿詳細を閲覧するためのページ
class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  PostPageState createState() => PostPageState();
}

class PostPageState extends State<PostPage> {
  double _dragOffset = 0.0; // ドラッグした距離を記録する変数
  bool _isClosing = false; // 画面を閉じるフラグ

  // ユーザーが指を動かすときに呼び出される処理
  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isClosing) return;
    setState(() {
      // ドラッグの移動量を記録
      _dragOffset += details.primaryDelta!;

      // 左に行かせないように、ドラッグ量が0より小さくならないようにする
      if (_dragOffset < 0) _dragOffset = 0;
    });
  }

  // ユーザーが指を離したときに呼ばれる処理
  void _handleDragEnd(DragEndDetails details) {
    // ドラッグした距離が100ピクセル以上なら、画面を閉じる処理を開始
    if (_dragOffset > 100) {
      setState(() => _isClosing = true); // 画面を閉じるフラグを立てる
      Navigator.of(context).pop(); // 現在の画面を閉じる
    } else {
      // 100ピクセル未満なら元の位置に戻す
      setState(() => _dragOffset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,  // 背景を透明にする
      // GestureDetectorでスライドアニメーションの部分のみ処理
      body: GestureDetector(
        // 水平ドラッグの更新を検知し、_handleDragUpdate を呼び出す
        onHorizontalDragUpdate: _handleDragUpdate,
        // 水平ドラッグが終了したときに呼ばれる処理
        onHorizontalDragEnd: _handleDragEnd,

        child: Stack(
          children: [
            // スライドアニメーションを適用する部分
            Transform.translate(
              offset: Offset(_dragOffset, 0),  // ドラッグ量に応じてウィジェットを移動
              child: Scaffold(
                appBar: AppBar(
                  // テーマに基づいた色をAppBarに設定（ダーク・ライトテーマ対応）
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  // 画面タイトルを表示（MyHomePageのtitleプロパティから取得）
                  title: const Text("投稿"),
                ),

                body: Container(
                  color: Colors.grey.shade300,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 0), // 上下に余白を0
                    itemCount: 20, // 投稿の数を指定（動的に変わる）
                    itemBuilder: (context, index) {
                      // 各投稿をカード形式で表示
                      return const PostCard(postId: "HELLOOOO!!!!",transition:false);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
