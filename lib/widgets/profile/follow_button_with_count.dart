import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/models/profile.dart';
import 'package:cordial/widgets/profile/dialog.dart';
import 'package:cordial/screens/edit_profile_page.dart';
import 'package:cordial/navigation/page_transitions.dart';
import 'package:cordial/function/database_write.dart';
import 'package:cordial/function/database_read.dart';

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

  // このユーザーをフォローしているか
  bool? isFollow;

  @override
  void initState() {
    super.initState();

    // フォロー,フォロワー数を取得
    setFollowCount();

    // ユーザーをフォローしているかを確認
    setIsFollowing();
  }

  // フォローしているかを判別する
  Future setIsFollowing() async {
    // 自分自身のページでないならフォローしているかを確認する。
    if (widget.userId != FirebaseAuth.instance.currentUser?.uid) {
      isFollow = await DatabaseRead.isFollowing(widget.userId);
    }
  }

  //プロフィールデータ格納用変数
  Profile? _profile;
  // フォロー,フォロワー数を取得
  Future setFollowCount() async {
    // データ取得を待つ
    _profile = await widget.profileFuture;

    if (!mounted)return;
    setState(() {
      // それぞれデータ挿入
      follows = _profile?.followCount ?? 0;
      followers = _profile?.followerCount ?? 0;
    });
  }

  // 編集画面に飛ばす
  void profileEdit(){
    PageTransitions.fromBottom(targetWidget: EditProfilePage(existingName: _profile?.name,), context: context);
  }

  // フォローボタンが押されたときに呼び出す
  void onFollow() async {
    if(isFollow == true)return;

    // フォロー処理を実行
    await DatabaseWrite.follow(widget.userId);

    if (!mounted)return;
    setState(() {
      // 見かけ上フォロワー数を一つ上げる(実際にも上がってる)
      followers = (followers ?? 0) + 1;
      isFollow = true;
    });
  }

  // フォロー解除ボタンが押されたときに呼び出す
  void onUnFollow() async {
    if(isFollow == false)return;

    // フォロー処理を実行
    await DatabaseWrite.unFollow(widget.userId);

    setState(() {
      // 見かけ上フォロワー数を一つ下げる(実際にも下がってる)
      followers = (followers ?? 0) - 1;
      isFollow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 通常フォローボタンを表示するが、自分自身のプロフィールの場合プロフィール編集ボタンを表示する
        widget.userId == FirebaseAuth.instance.currentUser?.uid
            ? ElevatedButton(
                onPressed: () {
                  // 編集を押したときの動作
                  profileEdit();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.black,
                  foregroundColor: Colors.green[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size(0, 35),
                ),
                child: Row(
                  children: [
                    Text('編集'),
                    Image.asset(
                      "assets/edit_icon.png",
                      width: 35,
                      height: 35,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            // =====フォローボタンを表示=====
            : ElevatedButton(
                onPressed: () {
                  // まだ読み込み中なら反応させない
                  if(isFollow == null)return;

                  if(isFollow!){
                    showCustomDialog(context:context,
                      offset:  const Offset(150, 150),
                      text: "フォロー解除しますか？",
                      onTap: (){
                        // フォロー解除
                        onUnFollow();
                        print("解除");
                      }
                    );
                  }
                  else{
                    // フォローする
                    onFollow();
                  }
                },
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.black,
                  foregroundColor: Colors.green[50],
                  backgroundColor: isFollow != null // 読み込み中でないなら
                      ? (isFollow! ? Colors.transparent : Theme.of(context).colorScheme.tertiary)
                      : Theme.of(context).colorScheme.tertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 35),
                ),
                child: isFollow != null // 読み込み中でないなら
                    ? (isFollow! ? const Text('フォロー済') : const Text('フォロー'))
                    : const Text('・・・'),
              ),
        const SizedBox(width: 4),

        // フォロー数とフォロワー数を取得して表示
        Text(
          "フォロー${follows ?? "..."}人\n"
          "フォロワー${followers ?? "..."}人",
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
          softWrap: true,
        ),
      ],
    );
  }
}
