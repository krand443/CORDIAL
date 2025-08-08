import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordial/data_models/group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/widgets/custom_appbar.dart';
import 'package:rive/rive.dart';
import 'package:cordial/data_models/user_summary_list.dart';
import 'package:cordial/services/database_read.dart';
import 'package:cordial/widgets/user_summary_card.dart';
import 'package:cordial/widgets/screen_lock.dart';

// グループのチャットから操作できるメニュー
class GroupMenu extends StatefulWidget {
  final Group groupInfo;

  const GroupMenu({super.key, required this.groupInfo});

  @override
  State<GroupMenu> createState() => GroupMenuState();
}

class GroupMenuState extends State<GroupMenu> {
  // 画面操作を無効化するためのウィジェットコントローラー
  final ScreenLockController _screenLockController = ScreenLockController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Row(
        children: [
          // 左側：透明な領域
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque, // 空のContainerでもタップを検知するため
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // 右側：メニュー
          Expanded(
            flex: 5,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  Expanded(
                    child: _memberListScrollView(),
                  ),
                  widget.groupInfo.leaderId ==
                          FirebaseAuth.instance.currentUser!.uid
                      ? Material(
                          color: Colors.transparent, // 背景色
                          child: ListTile(
                            leading: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            title: const Text('グループを削除する'),
                            onTap: () {},
                          ),
                        )
                      : const SizedBox(),
                  Material(
                    color: Colors.transparent, // 背景色
                    child: ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      title: const Text('グループを脱退する'),
                      onTap: () {
                        leaveGroupDialog();
                      },
                    ),
                  ),
                  const SafeArea(child: SizedBox()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  final ScrollController scrollController = ScrollController();

  Widget _memberListScrollView() {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        const CustomAppbar(titleText: 'メンバー'),
        _MemberWidget(
          parentScrollController: scrollController,
          groupId: widget.groupInfo.id,
        ),
      ],
    );
  }

  // グループ退会ダイアログ
  Future<void> leaveGroupDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            AlertDialog(
              // ダイアログの角を丸くする
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              // タイトル
              title: const Text(
                'グループ退会',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              // コンテンツ（テキストフィールドとキャンセルボタン）
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('グループを退会します。よろしいですか？※再入会するには招待をしてもらう必要がります。'),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () async {
                          // 画面操作を無効
                          _screenLockController.show();
                          await _leaveGroup();
                          _screenLockController.hide();

                          // グループ一覧に戻る
                          int count = 0;
                          Navigator.of(context).popUntil((route) {
                            return count++ >= 3;
                          });
                        },
                        child: const Text(
                          'はい',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'キャンセル',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            BarrierWidget(
              controller: _screenLockController,
              loadingIndicator: const CircularProgressIndicator(),
            ),
          ],
        );
      },
    );
  }

  // グループ退会処理
  Future<void> _leaveGroup() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentReference groupRef =
          db.collection('groups').doc(widget.groupInfo.id);

      await db.runTransaction((transaction) async {
        // グループ側を削除
        final deleteUserGroup = groupRef.collection('members').doc(uid);
        transaction.delete(deleteUserGroup);

        // ユーザー側も削除
        final deleteGroupUser = db
            .collection('users')
            .doc(uid)
            .collection('groups')
            .doc(widget.groupInfo.id);
        transaction.delete(deleteGroupUser);
      });
    } catch (e) {
      print('\x1B[31m$e\x1B[0m');
    }
  }
}

///////////////以下メンバー一覧を表示するクラス///////////////
class _MemberWidget extends StatefulWidget {
  // 親のスクロールコントローラーを受け取る
  final ScrollController parentScrollController;

  final String groupId;

  const _MemberWidget({
    required this.parentScrollController,
    required this.groupId,
  });

  @override
  State<_MemberWidget> createState() => _MemberWidgetState();
}

class _MemberWidgetState extends State<_MemberWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ステートを保持する

  // 最後までスクロールをしたときに投稿を追加するためのコントローラー
  late ScrollController _scrollController;

  late final String _groupId;

  // 投稿を取得しているかどうか
  bool _isLoading = false;

  // 投稿をすべて取得したかどうか
  bool _isShowAll = false;

  @override
  void initState() {
    super.initState();

    // コントローラーを親ウィジットから受け取る。
    _scrollController = widget.parentScrollController;

    _groupId = widget.groupId;

    userSummaryAdd(); // 初回表示時に実行される

    // 下の方までまでスクロールをしたとき更新
    _scrollController.addListener(() {
      print(_scrollController.position.pixels);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent -
                  300 // 画面の縦の高さは: 783.2727272727273
          &&
          !_isLoading &&
          !_isShowAll) {
        userSummaryAdd();
      }
    });
  }

  // ユーザー概要データを格納するリスト
  UserSummaryList? userSummaryList;

  // リストの要素を追加する関数
  Future userSummaryAdd() async {
    // ロード中を示す。
    _isLoading = true;

    UserSummaryList? additionalUserSummaryList =
        await DatabaseRead.groupMemberList(
            groupId: _groupId, lastVisible: userSummaryList?.lastVisible);

    // タイムラインを更新
    if (additionalUserSummaryList != null) {
      // もともとのタイムラインが空だったらそのまま挿入、でなければ更新
      setState(() {
        if (userSummaryList == null) {
          userSummaryList = additionalUserSummaryList;
        } else {
          userSummaryList!.userSummaries
              .addAll(additionalUserSummaryList.userSummaries);
          userSummaryList!.lastVisible = additionalUserSummaryList.lastVisible;
        }
      });

      // 要素は収まっているので追加の要素は存在しない。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent <=
                _scrollController.position.viewportDimension) {
          if (!mounted) return; // メモリリーク予防
          setState(() {
            _isShowAll = true;
          });
        }
      });
    } else {
      // リストを取得し終えたならelseになる
      // 取得し終えているならtrue
      _isShowAll = true;
      setState(() {});
    }

    // ロード中を外す
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin有効化のため

    // タイムラインなし&すべてみせきってないなら読み込み
    if (userSummaryList == null && !_isShowAll) {
      return const SliverFillRemaining(
        child: Center(
          child: SizedBox(
            height: 150,
            width: 150,
            child: RiveAnimation.asset(
              'assets/animations/load_icon.riv',
              animations: ['load'],
            ),
          ),
        ),
      );
    } else {
      return userSummaryList == null
          ? SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return UserSummaryCard(
                    userSummary: userSummaryList!.userSummaries[index],
                  );
                },
                childCount: userSummaryList!.userSummaries.length,
              ),
            );
    }
  }
}
