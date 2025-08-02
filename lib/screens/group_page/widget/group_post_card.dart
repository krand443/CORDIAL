import 'package:flutter/material.dart';
import 'package:cordial/utils/make_link_text.dart';
import 'package:cordial/data_models/post.dart';
import 'package:cordial/navigation/page_transitions.dart';
import 'package:cordial/screens/profile/profile_page.dart';
import 'package:cordial/widgets/icon.dart';

// グループチャット用に投稿のカードを生成するクラス
class GroupPostCard extends StatefulWidget {
  // ポストの内容を受け取る変数
  final Post post;

  const GroupPostCard({
    super.key,
    required this.post,
  });

  @override
  State<GroupPostCard> createState() => GroupPostCardState();
}

class GroupPostCardState extends State<GroupPostCard> with AutomaticKeepAliveClientMixin {
  //　親ウィジェットから変数を受け取る
  late Post _post;
  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override // スクロールしても状態を保持
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); //スクロールしても状態を保持

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
      child:Padding(
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
                  if (_post.response != '') _aiResponse(),

                ],
              ),
            ),
          ],
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
}
