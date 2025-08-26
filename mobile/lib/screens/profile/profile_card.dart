import 'package:flutter/material.dart';
import 'package:cordial/widgets/icon.dart';
import 'package:cordial/data_models/profile.dart';
import 'follow_button_with_count.dart';

// プロフィールカードウィジェットを返す
class ProfileCard extends StatefulWidget {
  // userIdを受け取ってから構築
  final String userId;

  final Future<Profile?>? profileFuture;

  const ProfileCard({super.key, required this.userId, required this.profileFuture});

  @override
  State<ProfileCard> createState() => ProfileCardState();
}

class ProfileCardState extends State<ProfileCard> {
  // プロフィールを取得する非同期変数
  Future<Profile?>? _profileFuture;
  late String _userId;

  @override
  void initState() {
    super.initState();

    // widgetから変数を受け取る
    _userId = widget.userId;

    // プロフィールデータをDBから取得
    _profileFuture = widget.profileFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 横幅設定
      width: MediaQuery.of(context).size.width * 0.9,
      // カード台紙
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        // 影
        boxShadow: const [
          BoxShadow(
            color: Colors.white70,
            blurRadius: 5,
            offset: Offset(0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      // プロフィールの中身（アイコン＋名前＋フォローボタン）
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            // アイコン台紙
            decoration: BoxDecoration(
              shape: BoxShape.circle, // 丸型
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            // アイコン
            child: UserIcon(userId: _userId, size: 40),
          ),

          const SizedBox(width: 20), // プロフィール画像と情報の間の余白

          // ユーザー情報エリア
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 横方向にスクロール可能
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ユーザー名を関数から取得
                  _userNameFuture(),
                  const SizedBox(height: 4),
                  // ユーザーID
                  Text(
                    _userId,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // フォローボタンとフォロー数を返す関数を呼ぶ
                  FollowCount(userId: _userId, profileFuture: _profileFuture),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ユーザー名をDBから取得して返す
  FutureBuilder<Profile?> _userNameFuture() {
    return FutureBuilder<Profile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        String result;

        // 完了まで-------
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          result = "..........";
        }else {
          result = snapshot.data?.name ?? '..........';
        }

        // ユーザー名を返す（長くても横スクロールで対応）
        return Text(
          result,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          softWrap: true,
        );
      },
    );
  }
}
