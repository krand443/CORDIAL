import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cordial/widgets/under_bar.dart';
import 'package:cordial/widgets/post_card.dart';

//投稿を作成する画面
class MakePostPage extends StatefulWidget {
  const MakePostPage({super.key});

  @override
  State<MakePostPage> createState() => MakePostPageState();
}

class MakePostPageState extends State<MakePostPage> {
  double _dragOffset = 0.0; // ドラッグした距離を記録する変数
  bool _isClosing = false; // 画面を閉じるフラグ

  late String randomHintText = randomMassage();

  // ユーザーが指を動かすときに呼び出される処理
  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isClosing) return;
    setState(() {
      // ドラッグの移動量を記録
      _dragOffset += details.primaryDelta!;

      // 上に行かせないように、ドラッグ量が0より小さくならないようにする
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
      backgroundColor: Colors.transparent, // 背景を透明にする
      // GestureDetectorでスライドアニメーションの部分のみ処理
      body: GestureDetector(
        // 垂直ドラッグの更新を検知し、_handleDragUpdate を呼び出す
        onVerticalDragUpdate: _handleDragUpdate,
        // 垂直ドラッグが終了したときに呼ばれる処理
        onVerticalDragEnd: _handleDragEnd,

        child: Stack(
          children: [
            // スライドアニメーションを適用する部分
            Transform.translate(
              offset: Offset(0, _dragOffset), // ドラッグ量に応じてウィジェットを移動
              child: Scaffold(
                backgroundColor: Colors.white,
                resizeToAvoidBottomInset: true, // ← キーボードに合わせてUIを押し上げる

                //closeボタンと投稿ボタンを配置
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent, // ← M3特有の "変色" を防ぐ！
                  automaticallyImplyLeading: false, // ← 左の戻るボタンを消す（必要なら）
                  title: Row(
                      //左右のスペースをまんべんなく使う
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // 左右に寄せる！
                      children: [
                        IconButton(
                          padding: const EdgeInsets.only(top: 0),
                          icon: const Icon(
                            Icons.close,
                            size: 45,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            _isClosing = true;
                            Navigator.of(context).pop(); // 現在の画面を閉じる
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0, right: 0),
                          child: TextButton(
                            onPressed: () {
                              print('投稿押された！');
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.inversePrimary, // ← 背景色
                              foregroundColor: Colors.white, // ← テキスト色
                              textStyle: const TextStyle(
                                fontSize: 18, // ← フォントサイズを指定
                              ),
                            ),
                            child: const Text('メッセージを送信&投稿'),
                          ),
                        )
                      ]),
                ),

                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // AIのアイコン
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.inversePrimary, // 枠線の色
                              width: 5, // 枠線の太さ
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 100,
                            backgroundImage: NetworkImage(
                              'https://www.to-bi.ac.jp/wp-content/uploads/sp_mv.jpg',
                            ),
                          ),
                        ),
                      ),

                      //ユーザーのアイコンと入力欄
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                              'https://videos.openai.com/vg-assets/assets%2Ftask_01jtqgenjbe9wrhdy83zwkant4%2F1746693299_img_0.webp?st=2025-05-08T06%3A45%3A36Z&se=2025-05-14T07%3A45%3A36Z&sks=b&skt=2025-05-08T06%3A45%3A36Z&ske=2025-05-14T07%3A45%3A36Z&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skoid=3d249c53-07fa-4ba4-9b65-0bf8eb4ea46a&skv=2019-02-02&sv=2018-11-09&sr=b&sp=r&spr=https%2Chttp&sig=SO%2F7eryTw%2FY2lKXRU%2BEZxjckSz%2BthwsLadK2AcxXtBE%3D&az=oaivgprodscus',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: TextField(
                              autofocus: true, // ← ウィジェット表示時に自動でフォーカス
                              maxLines: null, // ← 改行を許可する
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                // 入力欄に表示するヒントメッセージを生成
                                hintText: randomHintText,
                                contentPadding: const EdgeInsets.only(top: 30), //上に余白追加して表示位置を下げる
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //入力欄に薄く表示する参考テキストをランダムに生成
  String randomMassage()
  {
    //0.0～1未満の乱数生成
    var random = math.Random();
    //0~100のパーセンテージに変換
    double value = random.nextDouble() * 100;

    String result;

    //今回は10通り作成する
    switch(value~/20)
    {
      case 0:
        result = "今日は雨だったからテルテル坊主作ったんだ！";
        break;

      case 1:
        result = "チラシで手を切っちゃた。痛い";
        break;

      case 2:
        result = "気分がいい！とにかく最高！！！";
        break;

      case 3:
        result = "明日の注射めっちゃ怖い...";
        break;

      case 4:
        result = "今日は忙しかったからとにかく褒めて！";
        break;

      default :
        result = "今日はなんだかいい気分!!";
        break;

    }

    return result;
  }
}
