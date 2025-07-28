import 'package:flutter/material.dart';
import 'package:cordial/services/database_write.dart';
import 'dart:math' as math;
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:cordial/widgets/icon.dart';
import 'package:cordial/utils/app_preferences.dart';
import 'package:rive/rive.dart';
import 'package:showcaseview/showcaseview.dart';

// 投稿を作成する画面
class MakePostPage extends StatefulWidget {
  const MakePostPage({super.key});

  @override
  State<MakePostPage> createState() => MakePostPageState();
}

class MakePostPageState extends State<MakePostPage> {
  // テキスト管理用
  final TextEditingController _textController = TextEditingController();

  late final String _randomHintText = _randomMessage();

  // AIの画像パスを格納
  final List<String> _aiImagesPath = [
    'assets/AI_icon.webp',
    'assets/AI_icon2.webp',
    'assets/AI_icon3.webp',
  ];

  // 各AIの簡単な紹介
  final List<String> _aiIntroduction = [
    'どんな人とでも楽しく話せたら嬉しいなって思ってるよ。気軽に話しかけてくれたら、めっちゃ嬉しい！よろしくね〜',
    '思ったことは言う。遠慮しない。ムダなやりとりは嫌いだけど、ちゃんと話す気があるなら応えるよ。',
    '初めまして。私はあなたの心に寄り添いたいと思っています。どんなことでも、お話ししてくださったら嬉しいです。',
  ];

  int _selectedAiIndex = int.parse(AppPreferences.load(Variable.selectedAi) ?? '0');

  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      setState(() {}); // 入力変更で再描画
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(builder: (BuildContext showCaseContext) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true, // キーボードに合わせてUIを押し上げる

        // closeボタンと投稿ボタンを配置
        appBar: _appbar(showCaseContext),

        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),

              // AIをスワイプで選択
              SizedBox(height: 200, child: _selectAiCarousel(_aiImagesPath)),

              const SizedBox(
                height: 53,
              ),

              // ユーザーのアイコンと入力欄
              Showcase(
                key: _showcaseKeys[2],
                description: 'ここに内容を入力します。',
                child: Row(
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
                        maxLength: 300,
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
              ),
            ],
          ),
        ),
      );
    });
  }

  // チュ－トリアル表示用のキー
  final List<GlobalKey> _showcaseKeys = List.generate(10, (_) => GlobalKey());

  AppBar _appbar(BuildContext showCaseContext) {
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

      // ヘルプボタン
      title: IconButton(
        padding: const EdgeInsets.only(left: 0),
        icon: const Icon(
          Icons.help_outline,
          size: 35,
          color: Colors.grey,
        ),
        onPressed: () {
          // チュートリアル開始
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ShowCaseWidget.of(showCaseContext).startShowCase(_showcaseKeys);
          });
        },
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 20),
          child: Showcase(
            key: _showcaseKeys[3],
            description: '最後にこのボタンで投稿します。投稿内容によってはAIが多くのいいねをつけてくれます！\n※多くの人の目に触れるため、過度な表現はお控えください。',
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
        ),
      ],
    );
  }

  // AI選択のコントローラーを作成
  late final InfiniteScrollController _selectAiController =
      InfiniteScrollController(initialItem: _selectedAiIndex);

  // AIをスワイプで選択するためのウィジェット
  Widget _selectAiCarousel(List<String> images) {
    return Showcase(
      key: _showcaseKeys[0],
      description: '様々な性格のAIを選んで質問、相談することができます。',
      child: Stack(
        children: [
          // アイコンをスワイプで選択
          InfiniteCarousel.builder(
            itemCount: images.length,
            itemExtent: 220,
            loop: true,
            controller: _selectAiController,
            onIndexChanged: (int index) {
              setState(() {
                _selectedAiIndex = index;
              });
            },
            itemBuilder: (context, itemIndex, realIndex) {
              return Padding(
                padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        // 今何を選択しているのかを分かりやすくするための囲い
                        color: _selectAiController.selectedItem == itemIndex
                            ? Theme.of(context).colorScheme.tertiary
                            : Colors.transparent,
                        width: 5,
                      ),
                    ),
                    child: Transform.scale(
                      scale: _selectAiController.selectedItem == itemIndex
                          ? 1.0
                          : 0.85,// 中央のアイテムは拡大
                      child: CircleAvatar(
                        backgroundImage: AssetImage(images[itemIndex]),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 説明用テキスト
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: const Offset(0, 40),
              // 操作は背面に流す
              child: IgnorePointer(
                child: Showcase(
                  key: _showcaseKeys[1],
                  description: 'どのAIにするかは自己紹介を見て選びましょう！',
                  child: Container(
                    width: 300,
                    height: 100,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.7),// 半透明
                      borderRadius: BorderRadius.circular(16), // 丸み
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.1),// 影
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _aiIntroduction[_selectedAiIndex],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.5),
                    size: 70,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _selectAiController.nextItem();
                  },
                  icon: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.5),
                    size: 70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 投稿ボタンを押したときに呼ばれる処理
  void _post() {
    AppPreferences.save(Variable.selectedAi,_selectedAiIndex.toString());

    Navigator.pop(context); // 先に画面を閉じる
    Future.microtask(() {
      // アニメーション・DBへ書き込み
      _showRiveOverlayAndCheckAfterPost(context);
    });
  }

  // 投稿&アニメーション
  void _showRiveOverlayAndCheckAfterPost(BuildContext context) async {
    final overlay = Overlay.of(context);
    StateMachineController? controller;
    SMITrigger? checkTrigger;

    final OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 50,
            height: 50,
            child: RiveAnimation.asset(
              'assets/animations/loading_check.riv',
              fit: BoxFit.contain,
              stateMachines: const ['State Machine 1'],
              onInit: (artBoard) {
                controller = StateMachineController.fromArtboard(
                  artBoard,
                  'State Machine 1',
                );
                if (controller != null) {
                  artBoard.addController(controller!);
                  final input = controller!.findInput<bool>('Check');
                  if (input is SMITrigger) {
                    checkTrigger = input;
                  }
                }
              },
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // データベース書き込み完了を待つ
    await DatabaseWrite.addPost(
      _textController.text,
      _selectAiController.selectedItem,
    );

    // 書き込み後に check を発火
    checkTrigger?.fire();

    // 自動でオーバーレイ削除
    await Future.delayed(const Duration(seconds: 2));
    overlayEntry.remove();
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
