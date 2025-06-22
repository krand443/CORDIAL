import 'dart:async';

import 'package:cordial/services/database_write.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../utils/make_link_text.dart';
import '../screens/post_page.dart';
import '../data_models/post.dart';
import 'package:cordial/navigation/page_transitions.dart';
import 'package:cordial/screens/profile/profile_page.dart';

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

  @override
  Widget build(BuildContext context) {
    super.build(context); //スクロールしても状態を保持

    return Card(
      elevation: 0.1,
      // 背景色をここで指定
      color: Theme.of(context).colorScheme.primaryContainer,
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
              onClose: () {setState(() {});},// この画面を閉じたとき再描画する(いいねを付けた時など用)
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
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: _post.iconUrl != "null"
                      ? NetworkImage(_post.iconUrl) as ImageProvider
                      : const AssetImage("assets/user_default_icon.png"),
                ),
              ),

              const SizedBox(width: 12),

              // ユーザー情報と投稿内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ユーザー名（仮で固定）
                    Text(
                      _post.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _post.postedAt,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 9),
                    ),
                    const SizedBox(height: 4),

                    // 投稿内容
                    RichText(
                      text: makeLinkText(_post.postText, context, fontSize: 14),
                    ),

                    // AIアイコン&返信(replyがtrue、つまり投稿への返信であれば描画しない)
                    if (_post.response != '') aiResponse(), //関数は下で定義

                    // いいねアイコン
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // いいね数を表示
                          Text(_post.nice.toString()),
                          Padding(
                            padding: const EdgeInsets.only(right: 20, left: 10),
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
                                _likeTimer =
                                    Timer(const Duration(seconds: 2), () async {
                                  try {
                                    if (_post.isNice) {
                                      // いいね追加処理
                                      DatabaseWrite.nice(_post.id,
                                          parentId: _parentPostId ?? null);
                                    } else {
                                      // いいね削除処理
                                      DatabaseWrite.unNice(_post.id,
                                          parentId: _parentPostId ?? null);
                                    }
                                  } catch (e) {
                                    print("アップロードエラー: $e");
                                  }
                                });
                              },
                              splashColor:
                                  _post.isNice ? null : Colors.pink[100],
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
  Widget aiResponse() {
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
                const Align(
                  alignment: Alignment.centerRight,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundImage: AssetImage('assets/AI_icon.webp'),
                  ),
                ),
                const SizedBox(height: 4),

                // AIからの応答
                Text(
                  // レスポンス最後の改行を消す
                  _post.response.replaceFirst(RegExp(r'(\n)$'), ''),
                  softWrap: true,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
