import 'dart:io';

import 'package:cordial/function/database.dart';
import 'package:cordial/function/imageMG.dart';
import 'package:flutter/material.dart';
import 'package:cordial/widgets/post_card.dart';
import 'package:cordial/struct/profile.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  //プロフィールを取得する非同期変数
  Future<Profile?>? _profileFuture;

  late String _userId;

  @override
  void initState() {
    super.initState();

    //widgetから変数を受け取る
    _userId = widget.userId;

    //プロフィールデータをDBから取得
    _profileFuture = Database.profile(_userId);
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

    //アイコンをDBから取得して返す
    FutureBuilder<Profile?> iconFuture(){
      return FutureBuilder<Profile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          //完了まで透明
          if (snapshot.connectionState != ConnectionState.done ||
              !snapshot.hasData) {
            return const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white12,
            );
          }
          //もし応答がnullならデフォルトのアイコンを表示
          if (snapshot.data?.iconUrl == "null") {
            return const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/user_default_icon.png"),
            );
          }
          return CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(snapshot.data!.iconUrl), //画像を取得して表示
          );
        },
      );
    }

    //ユーザー名をDBから取得して返す
    FutureBuilder<Profile?> userNameFuture(){
      return FutureBuilder<Profile?>(
          future: _profileFuture,
          builder: (context, snapshot){
            String result;

            //完了まで-------
            if (snapshot.connectionState != ConnectionState.done ||
                !snapshot.hasData) {
              result = "..........";
            }
            //もし応答がnullなら
            else if (snapshot.data?.iconUrl == "null") {
              result = "unknown";
            }
            else{
              result = snapshot.data!.name;
            }

            //ユーザー名を返す（長くても横スクロールで対応）
            return Text(result,
              style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
              softWrap: true,);
          }
      );
    }

    //プロフィールカードを返す関数
    Container profileCard() {
      return Container(
        // 横幅は画面の85%に設定
        width: MediaQuery.of(context).size.width * 0.9,
        // 外観の装飾（白背景 + 角丸 + 影）
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          //影
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        // プロフィールの中身（アイコン＋名前＋フォローボタン）
        child:Row(
          children: [
            Container(
              //============カード台紙＝＝＝＝＝＝＝＝＝＝＝
              decoration: BoxDecoration(
                shape: BoxShape.circle, // 丸型
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              //＝＝＝＝＝＝＝＝＝＝＝＝＝＝アイコン＝＝＝＝＝＝＝＝＝＝＝
              child: iconFuture()
            ),

            const SizedBox(width: 20), // プロフィール画像と情報の間の余白

            // ===== ユーザー情報エリア =====
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // 横方向にスクロール可能
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ユーザー名を関数から取得
                    userNameFuture(),
                    const SizedBox(height: 4),
                    // ユーザーID
                    Text(
                      _userId,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ===== フォローボタン =====
                    ElevatedButton(
                      onPressed: () {
                        // フォローボタンを押したときの動作
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('フォロー'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Scaffold(
      // アプリ全体の構造を提供するウィジェット（AppBar・body・FABなど含む）
      appBar: AppBar(
        // テーマに基づいた色をAppBarに設定（ダーク・ライトテーマ対応）
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        surfaceTintColor: Colors.transparent, // ← M3特有の "変色" を防ぐ！
        // 画面タイトルを表示（MyHomePageのtitleプロパティから取得）
        title: const Text("ユーザー名"),
      ),

      // メインのスクロールビュー（カスタムスクロールでSliverを組み合わせてUIを構築）
      body: CustomScrollView(
        slivers: [
          // ===== プロフィールヘッダー部分（スクロール時に縮小） =====
          SliverAppBar(
            surfaceTintColor: Colors.transparent, // ← M3特有の "変色" を防ぐ！
            // AppBarの展開時の高さ（初期状態での高さ）
            expandedHeight: 200,
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
                // （必要なら）静的グラデーションは残してもOK
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100), // 移動量に合わせて高さを調整
              child: Container(
                // 上方向にピクセル移動
                transform: Matrix4.translationValues(0, -20, 0),
                child: Center(
                  //プロフィールカードを表示
                  child: profileCard(),
                ),
              ),
            ),
          ),

          // ===== 投稿リスト部分（スクロール可能）=====
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // 投稿1件ごとの表示
                return PostCard(postId: _posts[index]);
              },
              childCount: _posts.length, // 投稿数
            ),
          ),
        ],
      ),
    );
  }
}
