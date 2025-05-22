import 'package:flutter/material.dart';
import '../function/make_link_text.dart';
import '../screens/post_page.dart';
import '../models/post.dart';
import 'package:cordial/function/database_read.dart';

//投稿のカードを生成するクラス
class PostCard extends StatelessWidget {

  //ポストの内容を受け取る変数
  final Post post;

  //画面遷移を有効にするか否か
  final bool transition;

  //返信用か否か
  final bool reply;

  const PostCard({super.key,
    required this.post,
    this.transition = true,
    this.reply = false,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 0.1,
      color: Colors.white, // 背景色をここで指定
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        //side: BorderSide(color: Colors.grey.shade300, width: 0.2),
        side: BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          //もしtransitionが無効かされてれば、タップしても画面遷移しない
          if(!transition)return;
          //投稿を押したときはその投稿の詳細ページに飛ぶ
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false, // 透明な背景にする
              transitionDuration: const Duration(milliseconds: 200), // アニメーションの時間を指定
              pageBuilder: (context, animation, secondaryAnimation) => const PostPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // スライドインアニメーション
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0), // 右から登場
                    end: Offset.zero,               // 画面中央へ
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // プロフィールアイコン
              CircleAvatar(
                radius: 20,
                backgroundImage:post.iconUrl != "null"
                    ? NetworkImage(post.iconUrl) as ImageProvider
                    : const AssetImage("assets/user_default_icon.png"),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      post.postedAt,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 9
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 投稿内容
                    RichText(
                      text: makeLinkText(post.postText),
                    ),

                    // AIアイコン&返信(replyがtrue、つまり投稿への返信であれば描画しない)
                    if(!reply)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IntrinsicWidth(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 250),
                            // ← ここで最大幅を設定
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

                                //AIからの応答
                                Text(
                                  post.response,
                                  softWrap: true,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
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
