import 'package:flutter/material.dart';
import 'package:cordial/services/database_read.dart';
import 'package:cordial/data_models/user_summary_list.dart';
import 'package:cordial/widgets/custom_appbar.dart';
import 'package:cordial/screens/profile/user_summary_card.dart';
import 'package:rive/rive.dart';

// フォロー一覧とフォロワー一覧を表示するページ
class FollowListPage extends StatefulWidget {
  final String userId;

  const FollowListPage({super.key, required this.userId});

  @override
  State<FollowListPage> createState() => FollowListPageState();
}

class FollowListPageState extends State<FollowListPage> {
  final PageController _controller =
      PageController(initialPage: 1); // ここで2ページ目（index 1）を指定

  // リスト再構築用のキー
  Key _followingKey = UniqueKey();
  Key _followerKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView(
        controller: _controller,
        onPageChanged: (int index) {
          // 一番左にスワイプしたときに画面を閉じる
          if (index == 0) {
            Navigator.pop(context);
          }
        },
        children: [
          const SizedBox(),
          followingPage(), // フォローページ
          followerPage(), // フォロワーページ
        ],
      ),
    );
  }

  Widget followingPage() {
    // 最後までスクロールをしたときに要素を追加するためのコントローラー
    final ScrollController scrollController = ScrollController();
    return Container(
      key: _followingKey,
      color: Theme.of(context).scaffoldBackgroundColor,
      // 引っ張ってリロード
      child: RefreshIndicator(
        color: Theme.of(context).colorScheme.tertiary,
        onRefresh: () async {
          // 再読込
          setState(() {
            _followingKey = UniqueKey();
          });
        },
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            CustomAppbar(
              titleText: "フォロー",
              actions: [
                IconButton(
                  icon: Icon(Icons.keyboard_double_arrow_right,
                      color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () {
                    // 次のページ(フォロワー)
                    _controller.animateToPage(
                      2,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
            FollowersWidget(
              userId: widget.userId,
              parentScrollController: scrollController,
              isFollowing: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget followerPage() {
    // 最後までスクロールをしたときに要素を追加するためのコントローラー
    final ScrollController scrollController = ScrollController();

    return Container(
      key: _followerKey,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: RefreshIndicator(
        color: Theme.of(context).colorScheme.tertiary,
        onRefresh: () async {
          // 再読込
          setState(() {
            _followerKey = UniqueKey();
          });
        },
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            CustomAppbar(
              titleText: "フォロワー",
              leading: IconButton(
                icon: Icon(Icons.keyboard_double_arrow_left,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  // 前のページ(フォロー)
                  _controller.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
            FollowersWidget(
              userId: widget.userId,
              parentScrollController: scrollController,
            ),
          ],
        ),
      ),
    );
  }
}

///////////////以下フォロワーまたは、フォロー一覧を表示するクラス///////////////
class FollowersWidget extends StatefulWidget {
  // ユーザーidを受け取る
  final String userId;

  // 親のスクロールコントローラーを受け取る
  final ScrollController parentScrollController;

  // フォロー一覧であることを明示するフラグ
  final bool? isFollowing;

  const FollowersWidget({
    super.key,
    required this.userId,
    required this.parentScrollController,
    this.isFollowing,
  });

  @override
  State<FollowersWidget> createState() => FollowersWidgetState();
}

class FollowersWidgetState extends State<FollowersWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ステートを保持する

  // 最後までスクロールをしたときに投稿を追加するためのコントローラー
  late ScrollController _scrollController;

  // 投稿を取得しているかどうか
  bool _isLoading = false;

  // 投稿をすべて取得したかどうか
  bool _isShowAll = false;

  // タイムライン生成で使用するユーザーId
  String? _userId;

  // trueならフォロー一覧
  bool? _isFollowing;

  @override
  void initState() {
    super.initState();

    // ウィジェットから値を受け取る
    _userId = widget.userId;

    // コントローラーを親ウィジットから受け取る。
    _scrollController = widget.parentScrollController;

    // これがtrueならフォロー一覧を返す
    _isFollowing = widget.isFollowing;

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

    UserSummaryList? _userSummaryList = _isFollowing == true
        ? await DatabaseRead.followList(userId: _userId!)
        : await DatabaseRead.followerList(userId: _userId!);

    // タイムラインを更新
    if (_userSummaryList != null) {
      // もともとのタイムラインが空だったらそのまま挿入、でなければ更新
      setState(() {
        if (userSummaryList == null) {
          userSummaryList = _userSummaryList;
        } else {
          userSummaryList!.userSummaries.addAll(_userSummaryList.userSummaries);
          userSummaryList!.lastVisible = _userSummaryList.lastVisible;
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
                childCount: (() {
                  final postCount = userSummaryList!.userSummaries.length;
                  final adCount = (postCount / 7).floor();
                  return postCount + adCount + 2; // +2: ローディング + 余白
                })(),
                // 最後にローディング用ウィジェットを1つ追加
                (BuildContext context, int index) {
                  // 表示する投稿数
                  final postCount = userSummaryList!.userSummaries.length;

                  // 投稿と広告の総アイテム数を計算
                  final adInterval = 7; // ADを数投稿ごとに挟む
                  final adCount = (postCount / adInterval).floor();
                  final totalItemCount = postCount + adCount + 2; // +2 は読み込み＋余白

                  if (index == totalItemCount - 2) {
                    // 最後に読み込みを追加する
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: !_isShowAll
                            // 読み込みアニメーション
                            ? const CircularProgressIndicator(
                                color: Colors.blue,
                                backgroundColor: Colors.transparent,
                              )
                            : const SizedBox.shrink(), // falseのときは何も表示しない
                      ),
                    );
                  }

                  // 末端に余白を追加する
                  if (index == totalItemCount - 1) {
                    return const SizedBox(
                      height: 90,
                    );
                  }

                  // 広告を挿入する位置かどうかを判定
                  if ((index + 1) % (adInterval + 1) == 0) {
                    //return AdMob.getBannerAdUnit(); // 広告ウィジェット
                    return Text('こうこーく');
                  }

                  // 実際のポストのインデックスを算出
                  final adsBefore = (index / (adInterval + 1)).floor();
                  final cardIndex = index - adsBefore;

                  return UserSummaryCard(
                    userSummary: userSummaryList!.userSummaries[cardIndex],
                  );
                },
              ),
            );
    }
  }
}
