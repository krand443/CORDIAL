import 'package:flutter/material.dart';
import 'package:cordial/widgets/under_bar.dart';

class ProfilePage extends StatefulWidget
{
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール'),
      ),
      body: Center(
        child: Text('ここにプロフィール情報を表示'),
      ),

      // FABとBottomAppBarを合体させたウィジェットを配置
      bottomNavigationBar: SizedBox(
        height: 80, // Stackぶん余裕を持たせる
        child: UnderBar(),
      ),
    );
  }
}