import 'package:flutter/material.dart';
import 'package:cordial/screens/profile/profile_card.dart';
import 'package:cordial/screens/timeline/timeline_widget.dart';
import 'package:cordial/services/database_read.dart';
import 'package:cordial/data_models/profile.dart';

// プロフィール画面
class ProfilePage extends StatefulWidget {
  // プロフィールを取得するためのユーザーID
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late String _userId;
  // プロフィールを取得する非同期変数
  Future<Profile?>? _profileFuture;

  @override
  void initState() {
    super.initState();

    // widgetから変数を受け取る
    _userId = widget.userId;

    // プロフィールデータをDBから取得
    _profileFuture = DatabaseRead.profile(_userId);
  }

  // 最後までスクロールをしたときに投稿を追加するためのコントローラー
  final ScrollController _scrollController = ScrollController();

  // 画面をリロード
  Future _reload() async {
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
    return Scaffold(
      // メインのスクロールビュー（カスタムスクロールでSliverを組み合わせてUIを構築）
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.tertiary,
        onRefresh: _reload,
        child: Stack(
          children: [
            // 背景画像と投稿一覧
            CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // プロフィールヘッダー部分（スクロール時に縮小）
                _profileHeader(),

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
                    profileFuture: _profileFuture,
                    userId: _userId,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // プロフィールヘッダー部分
  Widget _profileHeader(){
    return SliverAppBar(
      // trueならスクロールしても残す
      pinned: false,
      // 戻るアイコンの非表示
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.transparent,
      // M3特有の変色を防ぐ
      // AppBarの展開時の高さ（初期状態での高さ）
      expandedHeight: 180,
      // スクロールに応じて伸縮するコンテンツ
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          // 背景画像（パララックスする）
          _backgroundWidget(),

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
    );
  }

  // 背景画像を表示する関数
  Widget _backgroundWidget(){
    return FutureBuilder<Profile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // 読み込み中
        } else if (snapshot.hasError) {
          return const Center(child: Text('エラーが発生しました'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('プロフィールが見つかりません'));
        } else {
          final profile = snapshot.data!;
          // 画像パスなどプロフィールに応じて動的に決定できる
          String imagePath = profile.backgroundPath;

          if(imagePath=='null')imagePath = 'assets/background/00001.jpg';

          return Image.asset(
            imagePath,
            alignment: Alignment.center,
            fit: BoxFit.cover,
          );
        }
      },
    );
  }
}
