import 'package:flutter/material.dart';
import '../function/make_link_text.dart';

//投稿のカードを生成するクラス
class PostCard extends StatelessWidget {
  final String postId;

  const PostCard({super.key,required this.postId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () {
          // タップ時の処理（デバッグ出力）
          print("投稿タップ: $postId");
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
