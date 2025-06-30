import 'package:flutter/material.dart';
import 'package:cordial/data_models/user_summary.dart';
import 'package:cordial/navigation/page_transitions.dart';
import 'package:cordial/screens/profile/profile_page.dart';
import 'package:cordial/widgets/follow_button.dart';

// ユーザー概要のカードを生成するクラス(主にフォロー一覧表示用)
class UserSummaryCard extends StatefulWidget {

  final UserSummary userSummary;

  const UserSummaryCard({
    super.key,
    required this.userSummary,
  });

  @override
  UserSummaryCardState createState() => UserSummaryCardState();
}

class UserSummaryCardState extends State<UserSummaryCard> with AutomaticKeepAliveClientMixin {

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
          // プロフィールに飛ぶ
          PageTransitions.fromRight(targetWidget: ProfilePage(userId: widget.userSummary.userId), context: context);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // プロフィールアイコン
              CircleAvatar(
                radius: 25,
                backgroundImage: widget.userSummary.iconUrl != "null"
                    ? NetworkImage(widget.userSummary.iconUrl) as ImageProvider
                    : const AssetImage("assets/user_default_icon.png"),
              ),

              const SizedBox(width: 12),

              // ユーザー情報と投稿内容
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ユーザー名（仮で固定）
                  Text(
                    widget.userSummary.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.userSummary.time,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 9),
                  ),
                ],
              ),

              // スペーサーを追加して、その後のウィジェットを右端に寄せる
              const Spacer(),

              // フォローボタンを配置
              FollowButton(userId: widget.userSummary.userId),
            ],
          ),
        ),
      ),
    );
  }
}
