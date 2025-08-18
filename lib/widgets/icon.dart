import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/services/database_read.dart';
import '../data_models/profile.dart';

// ユーザーアイコンを返す
class UserIcon extends StatefulWidget {
  // userIdを受け取ってから構築(引数になければログイン中のユーザー)
  final String? userId;

  final double size;

  const UserIcon({super.key, this.userId, required this.size});

  @override
  State<UserIcon> createState() => UserIconState();
}
class UserIconState extends State<UserIcon> {
  // プロフィールを取得する非同期変数
  Future<Profile?>? _profileFuture;
  late String _userId;
  late double _size;

  @override
  void initState() {
    super.initState();

    // widgetから変数を受け取る(なければログイン中のユーザー)
    _userId = widget.userId ?? FirebaseAuth.instance.currentUser!.uid;
    _size = widget.size;

    // プロフィールデータをDBから取得
    _profileFuture = DatabaseRead.profile(_userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Profile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        // 完了まで透明
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          return CircleAvatar(
            radius: _size,
            backgroundColor: Colors.brown[50],
          );
        }
        // もし応答がnullならデフォルトのアイコンを表示
        if (snapshot.data?.iconUrl == null) {
          return CircleAvatar(
            radius: _size,
            backgroundImage: const AssetImage('assets/user_default_icon.png'),
          );
        }
        return CircleAvatar(
          radius: _size,
          backgroundImage: NetworkImage(snapshot.data!.iconUrl!), // 画像を取得して表示
        );
      },
    );
  }
}

// AIアイコンを返す
class AiIcon extends StatelessWidget{
  final int selectedAiId;
  final double radius;

  AiIcon({super.key, required this.selectedAiId, required this.radius});

  // AIアイコンのリスト
  final List<String> filePath = [
    'assets/AI_icon.webp',
    'assets/AI_icon2.webp',
    'assets/AI_icon3.webp',
  ];

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage(filePath[selectedAiId]),
    );
  }

}
