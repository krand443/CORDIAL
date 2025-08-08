import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cordial/screens/group_page/widget/group_post_card.dart';
import 'package:cordial/services/database_read.dart';
import 'package:cordial/data_models/timeline.dart';
import 'package:cordial/data_models/post.dart';
import 'package:cordial/widgets/admob_widgets.dart';
import 'package:cordial/utils/network_status.dart';
import 'package:rive/rive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordial/utils/change_format.dart';

// グループチャットのタイムラインを表示するクラス
class GroupChatTimeline extends StatefulWidget {
  // グループidを受け取る
  final String groupId;

  const GroupChatTimeline({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupChatTimeline> createState() => GroupChatTimelineState();
}

class GroupChatTimelineState extends State<GroupChatTimeline>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ステートを保持する

  // 投稿データを格納するリスト
  Timeline? timeline;

  // 最後までスクロールをしたときに投稿を追加するためのコントローラー
  final ScrollController _scrollController = ScrollController();

  // 投稿を取得しているかどうか
  bool isLoading = false;

  // 投稿をすべて取得したかどうか
  bool isShowAll = false;

  // 新規投稿を入れる変数
  List<Post> newPosts = [];

  // 変更を監視するためのスナップショット
  late final StreamSubscription<QuerySnapshot> _chatSubscription; // 監視用
  late final Stream<QuerySnapshot> chatStream; // スナップショットのストリーム
  bool _chatStreamIsFirst = true;

  @override
  void initState() {
    super.initState();

    _initializeTimeline();

    // chatStreamを初期化
    chatStream = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('posts')
        .orderBy('postedAt', descending: true)
        .limit(1)
        .snapshots();

    // 上の方までまでスクロールをしたとき更新
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !isLoading &&
          !isShowAll) {
        _timelineAdd();
      }
    });
  }

  // タイムラインの初期化
  Future<void> _initializeTimeline() async {
    await _timelineAdd(); // 初回表示時にタイムラインを更新

    // 新しい投稿を監視する
    _chatSubscription = chatStream.listen((QuerySnapshot snapshot) {
      if (_chatStreamIsFirst) {
        _chatStreamIsFirst = false;
        return; // 初回は無視
      }

      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final newId = change.doc.id;
          // 初期IDと同じならスキップ（=既存データ）
          if (timeline?.lastVisible.id == newId) {
            continue;
          }

          // 投稿を画面に追加
          _newPostAdd(change);
        }
      }
    });
  }

  @override
  void dispose() {
    _chatSubscription.cancel(); // Firestore監視終了
    _scrollController.dispose(); // コントローラーを破棄
    super.dispose();
  }

  // 新しい投稿を画面に追加する関数
  Future<void> _newPostAdd(DocumentChange<Object?> change) async {
    final data = change.doc.data() as Map<String, dynamic>;
    print('新しい投稿: ${data['text']}');

    final postId = change.doc.id;
    final userId = data['userid'];

    final userFuture =
        FirebaseFirestore.instance.collection('users').doc(userId).get();

    final results = await Future.wait([userFuture]);

    // Postオブジェクトを作成して返す
    final post = Post(
      postedAt:
          ChangeFormat.timeAgoFromTimestamp(data['postedAt'] as Timestamp),
      id: postId,
      userId: userId,
      userName: results[0]['name'] ?? 'unknown',
      iconUrl: results[0]['iconUrl'],
      postText: data['text'] ?? '',
      selectedAiId: data['selectedAiId'] ?? 0,
      response: data['response'] ?? '',
      nice: 0,
      isNice: false,
    );

    setState(() {
      newPosts.insert(0, post);
    });

    // 最新の投稿を閲覧中なら
    // スクロールを一番下へ
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
        );
      });
    }

    return;
  }

  // タイムラインを追加する関数
  Future _timelineAdd() async {
    // ロード中を示す。
    isLoading = true;

    // タイムラインを取得
    Timeline? _timeline =
        await DatabaseRead.groupTimeline(widget.groupId, timeline?.lastVisible);

    // タイムラインを更新
    if (_timeline != null) {
      if (!mounted) return;

      // もともとのタイムラインが空だったらそのまま挿入、でなければ更新
      setState(() {
        if (timeline == null) {
          timeline = _timeline;
        } else {
          timeline!.posts.addAll(_timeline.posts);
          timeline!.lastVisible = _timeline.lastVisible;
        }
      });

      // 要素は収まっているので追加の要素は存在しない。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent <=
                _scrollController.position.viewportDimension) {
          if (!mounted) return;
          setState(() {
            isShowAll = true;
          });
        }
      });
    } else {
      // リストを取得し終えたならelseになる
      // 取得し終えているならtrue
      isShowAll = true;
      setState(() {});
    }

    // ロード中を外す
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin有効化のため

    // タイムラインなし&すべてみせきってないなら読み込み
    if (timeline == null && !isShowAll) {
      return const Center(
        child: SizedBox(
          height: 150,
          width: 150,
          child: RiveAnimation.asset(
            'assets/animations/load_icon.riv',
            animations: ['load'],
          ),
        ),
      );
    } else {
      return timeline == null && newPosts.isEmpty
          ? Container(
              padding: const EdgeInsets.only(top: 100),
              child: _noContentMessage(),
            )
          : Scrollbar(
              controller: _scrollController,
              thumbVisibility: true, // 常に表示する
              child: CustomScrollView(
                reverse: true,
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 新規投稿
                  ...newPosts.map(
                    (post) => SliverToBoxAdapter(
                      key: ValueKey(post.id),
                      child: GroupPostCard(
                        groupId: widget.groupId,
                        post: post,
                      ),
                    ),
                  ),

                  // タイムラインを取得する
                  _groupTimeline(),

                  const SliverToBoxAdapter(
                    child: SafeArea(child: SizedBox()),
                  ),
                ],
              ),
            );
    }
  }

  Widget _groupTimeline() {
    if(timeline == null)return const SliverToBoxAdapter(child: SizedBox());

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: (() {
          final postCount = timeline!.posts.length;
          final adCount = (postCount / 7).floor();
          return postCount + adCount + 1; // +1: ローディング
        })(),
        // 最後にローディング用ウィジェットを1つ追加
        (BuildContext context, int index) {
          // 表示する投稿数
          final postCount = timeline!.posts.length;

          // 投稿と広告の総アイテム数を計算
          const adInterval = 7; // ADを数投稿ごとに挟む
          final adCount = (postCount / adInterval).floor();
          final totalItemCount = postCount + adCount + 1; // +1 ローディング

          if (index == totalItemCount - 1) {
            // 最後に読み込みを追加する
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: !isShowAll
                    // 読み込みアニメーション
                    ? const CircularProgressIndicator(
                        color: Colors.blue,
                        backgroundColor: Colors.transparent,
                      )
                    : const SizedBox.shrink(), // falseのときは何も表示しない
              ),
            );
          }

          // 広告を挿入する位置かどうかを判定
          if ((index + 1) % (adInterval + 1) == 0) {
            return AdMob.getBannerAdUnit(); // 広告ウィジェット
          }

          // 実際のポストのインデックスを算出
          final adsBefore = (index / (adInterval + 1)).floor();
          final postIndex = index - adsBefore;

          return GroupPostCard(
              groupId: widget.groupId, post: timeline!.posts[postIndex]);
        },
      ),
    );
  }

  // タイムラインが取得できなかった場合に使用するメッセージ
  Widget _noContentMessage() {
    // 共通で使用する色
    Color textColor =
        Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.4);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FutureBuilder<bool>(
            future: NetworkStatus.check(), // ネットワーク接続状況で分岐
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // データ待ち（ローディング中）
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // エラー発生時
                return const Center(child: Text('エラーが発生しました'));
              } else if (snapshot.hasData && snapshot.data == true) {
                // 接続あり
                return Text(
                  'まだメッセージはありません。',
                  style: TextStyle(fontSize: 18, color: textColor),
                );
              } else {
                // 接続なし
                return Text(
                  'インターネット接続が確認できませんでした。',
                  style: TextStyle(fontSize: 18, color: textColor),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
