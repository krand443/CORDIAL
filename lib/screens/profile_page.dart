import 'package:cordial/function/database_read.dart';
import 'package:cordial/models/profile.dart';
import 'package:cordial/widgets/post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/widgets/profile_card.dart';

import '../models/post.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late String _userId;

  @override
  void initState() {
    super.initState();

    //widgetから変数を受け取る
    _userId = widget.userId;
    print(_userId);
  }

  // 投稿データを格納するリスト（ダミーデータを3件初期化）
  final List<String> _posts = [
    "こんにちは！FlutterでTwitter風アプリ作ってます。",
    "こんにちは！FlutterでTwitter風アプリ作ってます。",
    "こんにちは！FlutterでTwitter風アプリ作ってます。",
    "こんにちは！FlutterでTwitter風アプリ作ってます。",
    "こんにちは！FlutterでTwitter風アプリ作ってます。",
    "この投稿はダミーデータです。\njkasdhjakhsjashassakaskjk",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
    "スクロールしてたくさんの投稿を表示できます。https://youtube.com",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // メインのスクロールビュー（カスタムスクロールでSliverを組み合わせてUIを構築）
        body: Stack(
      children: [
        //背景画像と投稿一覧
        CustomScrollView(
          slivers: [
            // ===== プロフィールヘッダー部分（スクロール時に縮小） =====
            SliverAppBar(
              pinned: false,
              surfaceTintColor: Colors.transparent, // ← M3特有の "変色" を防ぐ！
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
                  //グラデーション
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

            // ===== 投稿リスト部分（スクロール可能）=====
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // 投稿1件ごとの表示
                  return const PostCard(
                      post: Post(
                          postedAt: "postedAt",
                          id: "id",
                          userId: "userId",
                          userName: "userName",
                          iconUrl:
                              "https://firebasestorage.googleapis.com/v0/b/projectcordial-596bd.firebasestorage.app/o/FtLtSLQqCnU1tL5OXbERtUaeJ842%2Ficon.png?alt=media&token=d41d9da1-a22a-4aab-9adf-8f542684495b",
                          postText: "postText",
                          response: "response",
                          nice: 0,
                          isNice: true));
                },
                childCount: _posts.length, // 投稿数
              ),
            ),
          ],
        ),

        //プロフィールカード
        Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 30),
              child: ProfileCard(
                userId: _userId,
              ),
            )),

        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'ログアウト',
          onPressed: () async {
            // Firebase のログアウト
            await FirebaseAuth.instance.signOut();

            // ログイン画面などに遷移（必要に応じて）
            if (!context.mounted) return; // 安全チェック（ウィジェットが dispose されてないか）

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
      ],
    ));
  }
}
