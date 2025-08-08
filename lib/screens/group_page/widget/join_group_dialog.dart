import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> joinGroupDialog(BuildContext context) async {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text(
            'グループに参加',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          content: isLoading
              ? SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.tertiary,)),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: codeController,
                      decoration: InputDecoration(
                        labelText: '招待コード入力',
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.paste,
                              color: Theme.of(context).colorScheme.tertiary),
                          onPressed: () async {
                            final clipboardData =
                                await Clipboard.getData(Clipboard.kTextPlain);
                            if (clipboardData?.text != null) {
                              codeController.text = clipboardData!.text!;
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 参加
                        TextButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });

                            final result =
                                await _joinGroup(codeController.text.trim());

                            Navigator.of(context).pop(); // ダイアログ閉じる

                            // 結果をSnackBarで表示
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                          child: Text(
                            '参加',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                            ),
                          ),
                        ),

                        // キャンセルボタン
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'キャンセル',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      });
    },
  );
}

// 参加処理
Future<String> _joinGroup(String invitationId) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  try {
    // 招待情報を読み込む
    var invitationDoc = await db
        .collection('invitations') // コレクションID
        .doc(invitationId)
        .get();

    // 存在しない or 必須フィールドが null の場合
    if (!invitationDoc.exists ||
        invitationDoc.data() == null ||
        invitationDoc['groupId'] == null ||
        invitationDoc['createdAt'] == null) {
      return '招待コードが無効です。';
    }

    // ユーザーのグループ参加状況を読み込む
    var joinedGroupsDoc = await db
        .collection('users') // コレクションID
        .doc(uid)
        .collection('groups') // コレクションID
        .doc(invitationDoc['groupId'])
        .get();

    // 既にグループに参加してるなら
    if (joinedGroupsDoc.exists) {
      return '既にグループに参加しています。';
    }

    final joinedGroupsCountSnapshot  = await db
        .collection('users')
        .doc(uid)
        .collection('groups')
        .count()
        .get();

    final int joinedGroupsCount = joinedGroupsCountSnapshot.count ?? 0;

    const int maxGroupCount = 30;
    if(joinedGroupsCount >= maxGroupCount)return '同時に参加できるグループは$maxGroupCount個までです。';

    Timestamp createdAt = invitationDoc['createdAt']; // FirestoreのTimestamp型
    DateTime now = DateTime.now();
    DateTime createdTime = createdAt.toDate();

    // 24時間以内かどうか判定
    bool isWithin24Hours =
        now.difference(createdTime) < const Duration(hours: 24);

    if (!isWithin24Hours) {
      return 'この招待コードは有効期限が切れています。';
    }

    // グループを追加
    try {
      await db.runTransaction((transaction) async {
        // グループ側にメンバーとして追加
        final addUserToGroup = db
            .collection('groups')
            .doc(invitationDoc['groupId'])
            .collection('members')
            .doc(uid);
        transaction.set(addUserToGroup, {
          'joinedAt': FieldValue.serverTimestamp(),
        });

        // ユーザー側にもグループ情報を追加
        final addGroupToUser = db
            .collection('users')
            .doc(uid)
            .collection('groups')
            .doc(invitationDoc['groupId']);
        transaction.set(addGroupToUser, {
          'joinedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      return 'グループの参加に失敗しました。';
    }

    return 'グループに参加しました！';
  } catch (e) {
    print('\x1B[31m$e\x1B[0m');
    return '招待コードが無効です。';
  }
}
