import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/services/database_read.dart';
import 'package:cordial/services/database_write.dart';
import 'package:cordial/widgets/dialog.dart';

class FollowButton extends StatefulWidget {
  final String userId;

  final VoidCallback? onFollow;
  final VoidCallback? onUnFollow;

  const FollowButton(
      {super.key, required this.userId, this.onFollow, this.onUnFollow});

  @override
  State<FollowButton> createState() => FollowButtonState();
}

class FollowButtonState extends State<FollowButton> {
  bool? isFollow;

  @override
  void initState() {
    super.initState();

    setIsFollowing();
  }

  // フォローしているかを判別する
  Future setIsFollowing() async {
    // 自分自身のページでないならフォローしているかを確認する。
    if (widget.userId != FirebaseAuth.instance.currentUser?.uid) {
      isFollow = await DatabaseRead.isFollowing(widget.userId);

      // 再読込
      if (!mounted) return;
      setState(() {});
    }
  }

  // フォローボタンが押されたときに呼び出す
  void onFollow() async {
    if (isFollow == true) return;

    // フォロー処理を非同期で実行
    DatabaseWrite.follow(widget.userId);

    // 登録された関数を実行
    widget.onFollow?.call();

    if (!mounted) return;
    setState(() {
      isFollow = true;
    });
  }

  // フォロー解除ボタンが押されたときに呼び出す
  void onUnFollow() async {
    if (isFollow == false) return;

    // フォロー処理を非同期で実行
    DatabaseWrite.unFollow(widget.userId);

    // 登録された関数を実行
    widget.onUnFollow?.call();

    if (!mounted) return;
    setState(() {
      isFollow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        if (isFollow == null) return;

        final globalPosition = details.globalPosition;

        if (isFollow!) {
          showCustomDialog(
            context: context,
            offset: globalPosition + const Offset(-120, 15),
            text: "フォロー解除しますか？",
            onTap: () {
              onUnFollow();
            },
          );
        } else {
          onFollow();
        }
      },
      child: AbsorbPointer(// onPressed を無効化
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.black,
            foregroundColor: Colors.green[50],
            backgroundColor: isFollow != null
                ? (isFollow!
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.tertiary)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 35),
          ),
          onPressed: () {},
          child: isFollow != null
              ? (isFollow! ? const Text('フォロー済') : const Text('フォロー'))
              : const Text('・・・'),
        ),
      ),
    );
  }
}
