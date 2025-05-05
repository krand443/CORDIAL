import 'package:flutter/material.dart';
import 'package:cordial/widgets/under_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // アプリ全体の構造を提供するウィジェット（AppBar・body・FABなど含む）
      appBar: AppBar(
        // テーマに基づいた色をAppBarに設定（ダーク・ライトテーマ対応）
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 画面タイトルを表示（MyHomePageのtitleプロパティから取得）
        title: const Text("ユーザー名"),
      ),

      body: CustomScrollView(
        slivers: [
          // プロフィールヘッダー部分（スクロールで縮小する）
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 背景画像
                  Image.network(
                    'https://min-chi.material.jp/mc/materials/background-c/single_room2/_single_room2_1.jpg',
                    fit: BoxFit.cover,
                  ),
                  // 背景画像の上に半透明のグラデーションを重ねる（テキストを見やすくするため）
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Container(
                transform: Matrix4.translationValues(0, 40, 0),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // プロフィール画像
                        Hero(
                          tag: 'profile-image',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
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
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                'https://abs.twimg.com/sticky/default_profile_images/default_profile_400x400.png',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // ユーザー情報
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "ユーザー名",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "@0123456789012345",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // フォローボタン
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                                child: const Text('フォローする'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // FABとBottomAppBarを合体させたウィジェットを配置
      bottomNavigationBar: const SizedBox(
        height: 80, // Stackぶん余裕を持たせる
        child: UnderBar(),
      ),
    );
  }
}
