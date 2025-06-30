import 'package:flutter/material.dart';
import 'package:cordial/services/database_write.dart';
import 'dart:math' as math;
import 'package:cordial/widgets/under_bar.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:cordial/widgets/icon.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

// 投稿を作成する画面
class MakePostPage extends StatefulWidget {
  const MakePostPage({super.key});

  @override
  State<MakePostPage> createState() => MakePostPageState();
}

class MakePostPageState extends State<MakePostPage> {
  // テキスト管理用
  final TextEditingController _textController = TextEditingController();

  // 投稿ボタンを押したときに呼ばれる処理
  void _post() {
    DatabaseWrite.addPost(
        _textController.text, _selectAiController.selectedItem); // ポスト追加
    Navigator.of(context).pop(); // 現在の画面を閉じる
  }

  late final String _randomHintText = _randomMessage();

  // AIの画像パスを格納
  final List<String> _aiImagesPath = [
    'assets/AI_icon.webp',
    'assets/AI_icon2.webp',
    'assets/AI_icon3.webp',
  ];
  final int _selectedAiIndex = 0;

  // AI選択のコントローラーを作成
  late final InfiniteScrollController _selectAiController =
      InfiniteScrollController(initialItem: _selectedAiIndex);

  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      setState(() {}); // 入力変更で再描画
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(30), // 上の角を丸くする
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true, // キーボードに合わせてUIを押し上げる

        // closeボタンと投稿ボタンを配置
        appBar: _appbar(),

        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),

              // AIをスワイプで選択
              SizedBox(height: 200, child: _selectAiCarousel(_aiImagesPath)),

              const SizedBox(
                height: 20,
              ),

              // ユーザーのアイコンと入力欄
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const UserIcon(size: 30),
                  const SizedBox(width: 8),
                  Flexible(
                    child: TextField(
                      autofocus: true,
                      // ウィジェット表示時に自動でフォーカス
                      maxLines: null,
                      // 改行を許可する
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        // 入力欄に表示するヒントメッセージを生成
                        hintText: _randomHintText,
                        contentPadding: const EdgeInsets.only(top: 20),
                        // 上に余白追加して表示位置を下げる
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
    );
  }

  AppBar _appbar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      // M3特有の変色を防ぐ！
      automaticallyImplyLeading: false,
      // 左端の戻るボタン
      leading: IconButton(
        padding: const EdgeInsets.only(top: 0),
        icon: const Icon(
          Icons.close,
          size: 30,
          color: Colors.grey,
        ),
        onPressed: () {
          Navigator.of(context).pop(); // 現在の画面を閉じる
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 20),
          child: TextButton(
            onPressed: () {
              // テキストが入力されていれば実行
              if (_textController.text.isNotEmpty) {
                _post();
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: _textController.text.isNotEmpty
                  ? Theme.of(context).colorScheme.tertiaryContainer
                  : Colors.grey,
              foregroundColor: _textController.text.isNotEmpty
                  ? Colors.white
                  : Colors.grey[50],
            ),
            child: const Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Icon(
                Icons.send,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // AIをスワイプで選択するためのウィジェット
  Widget _selectAiCarousel(List<String> images) {
    return Stack(
      children: [
        // アイコンをスワイプで選択
        InfiniteCarousel.builder(
          itemCount: images.length,
          itemExtent: 220,
          loop: true,
          controller: _selectAiController,
          onIndexChanged: (int index) {
            setState(() {});
          },
          itemBuilder: (context, itemIndex, realIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        // 今何を選択しているのかを分かりやすく
                        color: _selectAiController.selectedItem == itemIndex
                            ? Theme.of(context).colorScheme.tertiary
                            : Colors.transparent,
                        width: 5,
                      ),
                    ),
                    child: Transform.scale(
                      scale: _selectAiController.selectedItem == itemIndex
                          ? 1.0
                          : 0.85, // 中央のアイテムは拡大
                      child: CircleAvatar(
                        backgroundImage: AssetImage(images[itemIndex]),
                      ),
                    ),
                  )),
            );
          },
        ),

        // 矢印を表示
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  _selectAiController.previousItem();
                },
                icon: Icon(
                  Icons.chevron_left,
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                  size: 70,
                ),
              ),
              IconButton(
                onPressed: () {
                  _selectAiController.nextItem();
                },
                icon: Icon(
                  Icons.chevron_right,
                  color:
                  Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                  size: 70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 入力欄に薄く表示する参考テキストをランダムに生成
  String _randomMessage() {
    // 0.0～1未満の乱数生成
    var random = math.Random();
    // 0~100のパーセンテージに変換
    double value = random.nextDouble() * 100;

    String result;

    switch (value ~/ 20) {
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

      default:
        result = "今日はなんだかいい気分!!";
        break;
    }

    return result;
  }
}
