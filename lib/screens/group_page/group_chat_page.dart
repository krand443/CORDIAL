import 'package:cordial/services/database_write.dart';
import 'package:flutter/material.dart';
import 'package:cordial/screens/group_page/widget/group_chat_timeline.dart';
import 'package:cordial/widgets/icon.dart';
import 'package:vibration/vibration.dart';
import 'package:cordial/data_models/group.dart';

// グループチャットのページ
class GroupChatPage extends StatefulWidget {
  // グループ情報を受け取る
  final Group groupInfo;

  const GroupChatPage({super.key, required this.groupInfo});

  @override
  State<GroupChatPage> createState() => GroupChatPageState();
}

class GroupChatPageState extends State<GroupChatPage> {
  // テキスト管理用
  final TextEditingController _textController = TextEditingController();

  // テキスト入力に応じて送信ボタンを押せるようにする
  final ValueNotifier<String> _textValue = ValueNotifier('');

  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      // 入力変更で再描画
      _textValue.value = _textController.text;
    });
  }

  // 使用するAI
  int selectedAi = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupInfo.name,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: widget.groupInfo.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),

      // タイムラインを表示
      body: GroupChatTimeline(
        groupId: widget.groupInfo.id,
      ),

      // 投稿フィールド
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4), // 横方向のパディングを増やし、上下にもパディング
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(25), // 角を丸くする
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLength: 200,
                    buildCounter: (
                      BuildContext context, {
                      required int currentLength,
                      required bool isFocused,
                      required int? maxLength,
                    }) {
                      return null; // カウンターを非表示にする
                    },
                    decoration: InputDecoration(
                      hintText: 'メッセージを入力...',
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      // パディングを調整して中央寄せ
                      border: InputBorder.none,
                      // デフォルトの枠線をなくす
                      isDense: true, // パディングをさらにコンパクトに
                    ),
                    minLines: 1,
                    // 最小1行
                    maxLines: 5,
                    // 最大5行まで伸びるようにする
                    keyboardType: TextInputType.multiline, // 改行入力に対応
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // AIアイコン
              GestureDetector(
                onTap: () async {
                  setState(() {
                    selectedAi = ++selectedAi % 3;
                  });

                  if (await Vibration.hasVibrator()) {
                    Vibration.vibrate(duration: 50);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(2), // 枠と中身の間隔
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .tertiaryContainer, // 縁の色
                      width: 2.0, // 縁の太さ
                    ),
                    shape: BoxShape.circle, // 円形
                  ),
                  child: AiIcon(selectedAiId: selectedAi, radius: 20),
                ),
              ),

              const SizedBox(width: 5),

              // テキストの入力状況に応じて変更
              ValueListenableBuilder<String>(
                valueListenable: _textValue,
                builder: (context, value, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: value.isNotEmpty
                          ? Theme.of(context).colorScheme.tertiary
                          : Colors.grey, // ボタンの背景色
                      shape: BoxShape.circle, // 丸い形状
                    ),
                    child: Material(
                      // Materialウィジェットでラップして波紋エフェクトを有効にする
                      color: Colors.transparent, // Materialの背景色を透明にする
                      child: InkWell(
                        // InkWellでタップ可能にし、波紋エフェクトを追加
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          // 投稿を追加
                          if (_textController.text.isNotEmpty) {
                            // キーボードを閉じる
                            FocusScope.of(context).unfocus();
                            // 投稿を追加
                            DatabaseWrite.addGroupPost(widget.groupInfo.id, _textController.text, selectedAi);
                            // テキストをクリア
                            _textController.text = "";
                          }
                        },
                        child: const Padding(
                          // アイコンにパディングを追加
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
