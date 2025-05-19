import 'package:flutter/material.dart';
import '../function/make_link_text.dart';
import '../screens/post_page.dart';

//投稿のカードを生成するクラス
class PostCard extends StatelessWidget {
  final String postId;

  //画面遷移を有効にするか否か
  final bool transition;

  const PostCard({super.key,
    required this.postId,
    this.transition = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white, // 背景色をここで指定
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () {
          //もしtransitionが無効かされてれば、タップしても画面遷移しない
          if(!transition)return;
          // タップ時の処理（デバッグ出力）
          print("投稿タップ: $postId");
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
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://abs.twimg.com/sticky/default_profile_images/default_profile_400x400.png',
                ),
              ),
              const SizedBox(width: 12),

              // ユーザー情報と投稿内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ユーザー名（仮で固定）
                    const Text(
                      'ユーザーname',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '2025年5月19日 0:22:13 UTC+9',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 9
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 投稿内容
                    RichText(
                      text: makeLinkText(postId),
                    ),
                    // AIアイコン&返信
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
                                Text(
                                  postId,
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
