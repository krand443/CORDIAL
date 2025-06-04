import 'package:flutter/material.dart';
import '../function/make_link_text.dart';
import '../screens/post_page.dart';
import '../models/post.dart';
import 'package:cordial/navigation/page_transitions.dart';
import 'package:cordial/screens/profile_page.dart';

// 投稿のカードを生成するクラス
class PostCard extends StatelessWidget {
  // ポストの内容を受け取る変数
  final Post post;

  // 画面遷移を有効にするか否か
  final bool transition;

  const PostCard({
    super.key,
    required this.post,
    this.transition = true,
  });

  @override
  Widget build(BuildContext context) {

    // ダークモード時の色を少し薄めに設定したものを用意
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adjustedCardColor = isDark ? Colors.grey[250] : Colors.white;

    return Card(
      elevation: 0.1,
      // 背景色をここで指定
      color: adjustedCardColor,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      shadowColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white // ダークテーマなら薄い白の影
          : Colors.black, // ライトテーマなら薄い黒の影
      child: InkWell(
        onTap: () {
          // もしtransitionが無効かされてれば、タップしても画面遷移しない
          if (!transition) return;
          // 投稿を押したときはその投稿の詳細ページに飛ぶ
          PageTransitions.fromRight(PostPage(post: post), context);
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
                  PageTransitions.fromRight(ProfilePage(userId: post.userId,swipeEnabled:true), context);
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: post.iconUrl != "null"
                      ? NetworkImage(post.iconUrl) as ImageProvider
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
                      post.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      post.postedAt,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 9),
                    ),
                    const SizedBox(height: 4),

                    // 投稿内容
                    RichText(
                      text: makeLinkText(post.postText,context,fontSize: 14),
                    ),

                    // AIアイコン&返信(replyがtrue、つまり投稿への返信であれば描画しない)
                    if (post.response != "")
                      Row(
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
                                      backgroundImage:
                                          AssetImage('assets/AIicon.webp'),
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // AIからの応答
                                  Text(
                                    // レスポンス最後の改行を消す
                                    post.response.replaceFirst(RegExp(r'(\n)$'), ''),
                                    softWrap: true,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontSize: 12),
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
  }
}
