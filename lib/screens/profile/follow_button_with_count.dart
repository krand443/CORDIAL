import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/data_models/profile.dart';
import 'package:cordial/screens/profile/follow_list_page.dart';
import 'package:cordial/screens/edit_profile/edit_profile_page.dart';
import 'package:cordial/navigation/page_transitions.dart';
import 'package:cordial/widgets/follow_button.dart';

// フォローボタンとフォロー数フォロワー数widgetを返すクラス。
// 新規フォローすると見た目のみ数値を増やす。
class FollowCount extends StatefulWidget {
  // プロフィール情報を受け取る
  final Future<Profile?>? profileFuture;

  // ユーザーidを受け取る
  final String userId;

  const FollowCount(
      {super.key, required this.userId, required this.profileFuture});

  @override
  State<FollowCount> createState() => FollowCountState();
}

class FollowCountState extends State<FollowCount> {
  // フォロー数とフォロワー数を格納する変数
  int? follows, followers;

  @override
  void initState() {
    super.initState();

    // フォロー,フォロワー数を取得
    _setFollowCount();

  }

  //プロフィールデータ格納用変数
  Profile? _profile;

  // フォロー,フォロワー数を取得
  Future _setFollowCount() async {
    // データ取得を待つ
    _profile = await widget.profileFuture;

    if (!mounted) return;
    setState(() {
      // それぞれデータ挿入
      follows = _profile?.followCount ?? 0;
      followers = _profile?.followerCount ?? 0;
    });
  }

  // フォローボタンが押されたときに呼び出す
  void onFollow() async {
    if (!mounted) return;
    setState(() {
      // 見かけ上フォロワー数を一つ上げる(実際にも上がってる)
      followers = (followers ?? 0) + 1;
    });
  }

  // フォロー解除ボタンが押されたときに呼び出す
  void onUnFollow() async {
    if (!mounted) return;
    setState(() {
      // 見かけ上フォロワー数を一つ下げる(実際にも下がってる)
      followers = (followers ?? 0) - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 通常フォローボタンを表示するが、自分自身のプロフィールの場合プロフィール編集ボタンを表示する
        widget.userId == FirebaseAuth.instance.currentUser?.uid
            ? _editButton()
            : FollowButton(userId: widget.userId,onFollow: onFollow,onUnFollow: onUnFollow,),

        // フォロー数とフォロワー数を取得して表示
        Container(
          color: Colors.transparent,
          child: InkResponse(
            onTap: () {
              PageTransitions.fromRight(
                  targetWidget: FollowListPage(userId: widget.userId,), context: context);
            },
            child: Text(
              "フォロー${follows ?? "..."}人\n"
              "フォロワー${followers ?? "..."}人",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }

  // 編集ボタン
  Widget _editButton(){
    return ElevatedButton(
      onPressed: () {
        // 編集を押したときの動作
        PageTransitions.fromBottom(
            targetWidget: EditProfilePage(
              existingName: _profile?.name,
              backgroundPath: _profile?.backgroundPath,
            ),
            context: context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.black,
        foregroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 35),
      ),
      child: Row(
        children: [
          const Text('編集'),
          Image.asset(
            "assets/edit_icon.png",
            width: 35,
            height: 35,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
