import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/widgets/profile/profile_card.dart';
import 'package:cordial/widgets/timeline/timeline_widget.dart';
import 'package:cordial/navigation/swipe_back_wrapper.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  // プロフィールを取得するためのユーザーID
  final String userId;

  // trueならスワイプして画面を一つ前に戻せる
  final bool swipeEnabled;


  const ProfilePage({super.key, required this.userId, this.swipeEnabled = false});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late String _userId;

  @override
  void initState() {
    super.initState();

    // widgetから変数を受け取る
    _userId = widget.userId;
  }

  // 最後までスクロールをしたときに投稿を追加するためのコントローラー
  final ScrollController _scrollController = ScrollController();

  // 画面をリロード
  Future reload() async {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget, // super.widget ではなく widget
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // スワイプで戻せるようにするならSwipeBackWrapperでラップする
    if(widget.swipeEnabled == true){
      return SwipeBackWrapper(child: page(context),);
    }
    else{
      return page(context);
    }
  }

  // UI本体
  Widget page(BuildContext context){
    return Scaffold(
      // メインのスクロールビュー（カスタムスクロールでSliverを組み合わせてUIを構築）
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: RefreshIndicator(
          onRefresh: reload,
          child: Stack(
            children: [
              // 背景画像と投稿一覧
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // ===== プロフィールヘッダー部分（スクロール時に縮小） =====
                  SliverAppBar(
                    // trueならスクロールしても残す
                    pinned: false,
                    // 戻るアイコンの非表示
                    automaticallyImplyLeading: false,
                    surfaceTintColor: Colors.transparent, // M3特有の変色を防ぐ
                    // AppBarの展開時の高さ（初期状態での高さ）
                    expandedHeight: 180,
                    // スクロールに応じて伸縮するコンテンツ
                    flexibleSpace: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 背景画像（パララックスする）
                        Image.network(
                          'https://min-chi.material.jp/mc/materials/background-c/single_room2/_single_room2_1.jpg',
                          alignment: Alignment.topCenter,
                          fit: BoxFit.cover,
                        ),
                        // グラデーション
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.01),
                                Colors.black.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // タイムラインを取得
                  TimelineWidget(
                      parentScrollController: _scrollController,
                      userId: _userId),
                ],
              ),

              // プロフィールカード
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: ProfileCard(
                      userId: _userId,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
