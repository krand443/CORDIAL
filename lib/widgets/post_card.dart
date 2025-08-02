import 'dart:async';
import 'package:cordial/services/database_write.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:cordial/screens/report_page.dart';
import 'package:cordial/utils/make_link_text.dart';
import 'package:cordial/screens/post_page.dart';
import 'package:cordial/data_models/post.dart';
import 'package:cordial/navigation/page_transitions.dart';
import 'package:cordial/screens/profile/profile_page.dart';
import 'package:cordial/widgets/icon.dart';
import 'package:cordial/widgets/dialog.dart';

// 投稿のカードを生成するクラス
class PostCard extends StatefulWidget {
  // ポストの内容を受け取る変数
  final Post post;

  // 親投稿IDを格納(これが送られてきたらそれは返信用のカード)
  final String? parentPostId;

  // 画面遷移を有効にするか否か
  final bool transition;

  const PostCard({
    super.key,
    required this.post,
    this.transition = true,
    this.parentPostId,
  });

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> with AutomaticKeepAliveClientMixin {
  //　親ウィジェットから変数を受け取る
  late Post _post;
  late final bool _transition;
  late final String? _parentPostId;

  // いいね連打対応措置に使うカウント用変数
  Timer? _likeTimer;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _transition = widget.transition;
    _parentPostId = widget.parentPostId;
  }

  @override // スクロールしても状態を保持
  bool get wantKeepAlive => true;

  // 削除アイコン用のキー
  final GlobalKey deleteIconKey = GlobalKey();

  // この投稿が削除されたらtrueになり、表示を変更する
  bool isDeleted = false;

  @override
  Widget build(BuildContext context) {
    super.build(context); //スクロールしても状態を保持

    // 投稿が削除されたらこのウィジェットを返す
    if(isDeleted) {
      return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.grey),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'この投稿は削除されました',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
    }

    return Card(
      elevation: 0.1,
      // 背景色をここで指定
      color: Theme.of(context).colorScheme.primary,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      shadowColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white // ダークテーマなら薄い白の影
          : Colors.black,
      // ライトテーマなら薄い黒の影
      child: InkWell(
        onTap: () {
          // もしtransitionが無効かされてれば、タップしても画面遷移しない
          if (!_transition) return;
          // 投稿を押したときはその投稿の詳細ページに飛ぶ
          PageTransitions.fromRight(
            targetWidget: PostPage(
              post: _post,
            ),
            context: context,
            onClose: () {
              setState(() {});
            }, // この画面を閉じたとき再描画する(いいねを付けた時など用)
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // プロフィールアイコン
              InkResponse(
                onTap: () {
                  // アイコンがタップされたらプロフィールに飛ぶ
                  PageTransitions.fromRight(
                      targetWidget: ProfilePage(userId: _post.userId),
                      context: context);
                },
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 0.5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: _post.iconUrl != null
                        ? NetworkImage(_post.iconUrl!) as ImageProvider
                        : const AssetImage("assets/user_default_icon.png"),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ユーザー情報と投稿内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            // ユーザー名（仮で固定）
                            Text(
                              _post.userName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _post.postedAt,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 9),
                            ),
                          ],
                        ),

                        // 自分の投稿なら削除UIを表示
                        _post.userId == FirebaseAuth.instance.currentUser!.uid
                            ? IconButton(
                                key: deleteIconKey,
                                onPressed: () {
                                  final RenderBox renderBox = deleteIconKey
                                      .currentContext!
                                      .findRenderObject() as RenderBox;
                                  final Offset offset = renderBox
                                      .localToGlobal(Offset.zero); // 画面上の位置

                                  showCustomDialog(
                                      context: context,
                                      onTap: () async{
                                        DatabaseWrite.deletePost(_post.id);

                                        setState(() {
                                          isDeleted = true;
                                        });
                                      },
                                      offset: offset + const Offset(-150, 15),
                                      text: 'この投稿を削除しますか？\n削除後は復元できません\n※タップで確定');
                                },
                                icon: const Icon(
                                  Icons.delete_forever_sharp,
                                  color: Colors.red,
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // 投稿内容
                    RichText(
                      text: makeLinkText(_post.postText, context, fontSize: 14),
                    ),

                    // AIアイコン&返信(replyがtrue、つまり投稿への返信であれば描画しない)
                    if (_post.response != '') _aiResponse(),

                    // 下部ボタン
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _niceWidget(),
                          const SizedBox(
                            width: 10,
                          ),
                          _reportWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //AIの返信を表示するウィジェット
  Widget _aiResponse() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            // ここで最大幅を設定
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),

                Align(
                  alignment: Alignment.centerRight,
                  child: AiIcon(
                    selectedAiId: _post.selectedAiId,
                    radius: 18,
                  ),
                ),
                const SizedBox(height: 4),

                // AIからの応答
                Text(
                  // レスポンス最後の改行を消す
                  _post.response.replaceFirst(RegExp(r'(\n)$'), ''),
                  softWrap: true,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // いいねボタン
  Widget _niceWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // いいね数を表示
        Text(_post.nice.toString()),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: InkResponse(
            onTap: () {
              setState(() {
                // いいねを切り替え
                _post.isNice = !_post.isNice;
                _post.nice += _post.isNice ? 1 : -1;
              });

              // 既存のタイマーがあればキャンセル（連打対策）
              _likeTimer?.cancel();

              // 連打してもDBに複数回アクセスしないように数秒待ってから実行する
              _likeTimer = Timer(const Duration(seconds: 2), () async {
                try {
                  if (_post.isNice) {
                    // いいね追加処理
                    DatabaseWrite.nice(_post.id, parentId: _parentPostId);
                  } else {
                    // いいね削除処理
                    DatabaseWrite.unNice(_post.id, parentId: _parentPostId);
                  }
                } catch (e) {
                  print("アップロードエラー: $e");
                }
              });
            },
            splashColor: _post.isNice ? null : Colors.pink[100],
            // 波紋の色
            highlightColor: Colors.transparent,
            radius: 10,
            child: SizedBox(
              height: 25,
              width: 25,
              child: Transform.scale(
                scale: 2, // 拡大倍率
                child: RiveAnimation.asset(
                  'assets/animations/like.riv',
                  animations: [_post.isNice ? 'like' : 'dislike'],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 通報ボタン
  Widget _reportWidget() {
    return InkResponse(
      onTap: () {
        PageTransitions.fromBottom(
          targetWidget: ReportPage(
            postId: _post.id,
          ),
          context: context,
        );
      },
      radius: 10,
      child: SizedBox(
        height: 25,
        width: 25,
        child: Transform.scale(
          scale: 1, // 拡大倍率
          child: const Icon(Icons.flag_rounded, color: Color(0xFFCACACA)),
        ),
      ),
    );
  }
}
