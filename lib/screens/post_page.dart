import 'package:flutter/material.dart';
import 'package:cordial/widgets/post_card.dart';
import 'package:cordial/models/post.dart';
import 'package:cordial/function/database_write.dart';
import 'package:cordial/navigation/swipe_back_wrapper.dart';
import 'package:cordial/widgets/timeline_widget.dart';

//投稿詳細を閲覧するためのページ
class PostPage extends StatefulWidget {
  final Post post;

  const PostPage({super.key, required this.post});

  @override
  PostPageState createState() => PostPageState();
}

class PostPageState extends State<PostPage> {
  late Post _post;

  //テキスト管理用
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _post = widget.post;

    _textController.addListener(() {
      setState(() {}); // 入力変更で再描画
    });
  }

  //最後までスクロールをしたときに投稿を追加するためのコントローラー
  final ScrollController _scrollController = ScrollController();

  //再読込用のkey
  Key _reloadKey = UniqueKey();

  //画面をリロード
  Future reload() async {
    setState(() {
      _reloadKey = UniqueKey(); //強制再構築のためのキー更新
    });
  }

  //リプライを追加する
  Future addReply(String text) async {
    await DatabaseWrite.addReply(_post.id, _textController.text);
    reload();
  }

  @override
  Widget build(BuildContext context) {
    //SwipeBackWrapperでスライドで前画面に戻る
    return SwipeBackWrapper(
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          // テーマに基づいた色をAppBarに設定（ダーク・ライトテーマ対応）
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // 画面タイトルを表示（MyHomePageのtitleプロパティから取得）
          title: const Text("投稿"),
        ),
        body: Container(
          color: Colors.grey.shade300,
          //再読込
          child: RefreshIndicator(
            onRefresh: reload,

            //投稿とその返信
            child: CustomScrollView(
              controller: _scrollController,
              //投稿とその返信の位一覧
              slivers: [
                SliverToBoxAdapter(
                  child: PostCard(
                    post: _post,
                    transition: false,
                  ),
                ),

                //返信を挿入
                TimelineWidget(
                    key: _reloadKey, //再読込用
                    postId: _post.id,
                    parentScrollController: _scrollController),
              ],
            ),
          ),
        ),

        //返信フィールド
        bottomNavigationBar: SafeArea(
          child: Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4), // 横方向のパディングを増やし、上下にもパディング
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200], //薄いグレーの背景色
                        borderRadius: BorderRadius.circular(25), //角を丸くする
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'メッセージを入力...',
                          hintStyle:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          //パディングを調整して中央寄せ
                          border: InputBorder.none,
                          //デフォルトの枠線をなくす
                          isDense: true, //パディングをさらにコンパクトに
                        ),
                        minLines: 1,
                        // 最小1行
                        maxLines: 5,
                        // 最大5行まで伸びるようにする
                        keyboardType: TextInputType.multiline, //改行入力に対応
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // 送信ボタンとの間にスペースを追加
                  Container(
                    decoration: BoxDecoration(
                      color: _textController.text.isNotEmpty
                          ? Colors.blueAccent
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
                          //リプライを追加
                          if (_textController.text.isNotEmpty) {
                            addReply(_textController.text);
                            // キーボードを閉じる
                            FocusScope.of(context).unfocus();
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
