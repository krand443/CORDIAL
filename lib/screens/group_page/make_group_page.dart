import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/screens/group_page/widget/group_bar_widget.dart';
import 'package:cordial/data_models/group.dart';
import 'package:cordial/services/database_write.dart';
import 'package:cordial/widgets/screen_lock.dart';

// グループのタイトルウィジェットを返すクラス
class MakeGroupPage extends StatefulWidget {
  const MakeGroupPage({super.key});

  @override
  State<MakeGroupPage> createState() => MakeGroupPageState();
}

class MakeGroupPageState extends State<MakeGroupPage> {
  late Group _group;

  // テキスト管理用
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _group = Group(
      id: '',
      name: '新しいグループ',
      leaderId: '',
      icon: Icons.star,
      backgroundColor: Colors.red.shade600,
      numPeople: 1,
      lastAction: null,
    );

    // 入力変更で再描画
    _textController.addListener(() {
      setState(() {
        _group.name = _textController.text;

        if (_group.name == '') _group.name = '新しいグループ';
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  final presetColors = [
    Colors.red.shade600,
    Colors.pink.shade400,
    Colors.purple.shade500,
    Colors.deepPurple.shade400,
    Colors.indigo.shade400,
    Colors.blue.shade500,
    Colors.lightBlue.shade400,
    Colors.cyan.shade500,
    Colors.teal.shade400,
    Colors.green.shade500,
    Colors.lightGreen.shade600,
    Colors.amber.shade700,
    Colors.orange.shade600,
    Colors.brown.shade500,
  ];

  // 画面操作を無効化するためのウィジェットコントローラー
  final ScreenLockController _screenLockController = ScreenLockController();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: _appbar(),
        body: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                GroupBarWidget(
                  translation: false,
                  groupInfo: _group,
                ),
                const SizedBox(height: 20,),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presetColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _group.backgroundColor = color;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final icon = await showIconPicker(context);
                        if (icon != null) {
                          setState(() {
                            _group.icon = icon;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                      child: Text(
                        'アイコンを選択',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                TextField(
                  autofocus: true,
                  // ウィジェット表示時に自動でフォーカス
                  maxLength: 15,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'グループ名',
                    contentPadding: EdgeInsets.only(top: 20),
                    // 上に余白追加して表示位置を下げる
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      BarrierWidget(
        controller: _screenLockController,
        loadingIndicator: const CircularProgressIndicator(),
      ),
    ],);
  }

  AppBar _appbar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      // M3特有の変色を防ぐ！
      automaticallyImplyLeading: false,

      title: Text(
        'グループを作成',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),

      // 左端の戻るボタン
      leading: IconButton(
        padding: const EdgeInsets.only(top: 0),
        icon: const Icon(
          Icons.close,
          size: 30,
          color: Colors.grey,
        ),
        onPressed: () {
          Navigator.of(context).pop(); // 現在の画面を閉じる
        },
      ),

      actions: [
        Container(
          decoration: BoxDecoration(
            color: _textController.text.trim().isNotEmpty ? Theme.of(context).colorScheme.tertiaryContainer : Colors.grey,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(50, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            onPressed: () async{
              // 30個グループに入っていたら作成不可
              final FirebaseFirestore db = FirebaseFirestore.instance;
              final joinedGroupsCountSnapshot  = await db
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('groups')
                  .count()
                  .get();
              final int joinedGroupsCount = joinedGroupsCountSnapshot.count ?? 0;
              const int maxGroupCount = 30;
              if(joinedGroupsCount >= maxGroupCount){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('同時に参加できるグループは$maxGroupCount個までです。'),
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }


              if(_textController.text.trim().isEmpty)return;

              // 画面操作を無効
              _screenLockController.show();

              await DatabaseWrite.makeGroup(_group.name, _group.icon, _group.backgroundColor);

              if(!mounted)return;

              // 画面操作を有効化
              _screenLockController.hide();
              Navigator.of(context).pop(_group);// 画面を閉じる
            },
            child: const Text(
              '確定',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<IconData?> showIconPicker(BuildContext context) async {
    final icons = [
      Icons.star,
      Icons.star_border,
      Icons.favorite,
      Icons.favorite_border,
      Icons.thumb_up,
      Icons.thumb_up_alt,
      Icons.thumb_up_off_alt,
      Icons.recommend,
      Icons.whatshot,
      Icons.cake,
      Icons.celebration,
      Icons.event,
      Icons.card_giftcard,
      Icons.wine_bar,
      Icons.local_bar,
      Icons.local_cafe,
      Icons.restaurant,
      Icons.handshake,
      Icons.volunteer_activism,
      Icons.connect_without_contact,
      Icons.emoji_people,
      Icons.sports_soccer,
      Icons.sports_esports,
      Icons.sports_basketball,
      Icons.sports_tennis,
      Icons.music_note,
      Icons.movie,
      Icons.games,
      Icons.palette,
      Icons.brush,
      Icons.camera_alt,
      Icons.photo_camera,
      Icons.travel_explore,
      Icons.flight,
      Icons.hiking,
      Icons.book,
      Icons.menu_book,
      Icons.auto_stories,
      Icons.videogame_asset,
      Icons.theater_comedy,
      Icons.mic,
      Icons.piano,
      Icons.headphones,
      Icons.audiotrack,
      Icons.school,
      Icons.cast_for_education,
      Icons.menu_book,
      Icons.laptop_chromebook,
      Icons.computer,
      Icons.work,
      Icons.business,
      Icons.apartment,
      Icons.domain,
      Icons.lightbulb,
      Icons.engineering,
      Icons.science,
      Icons.language,
      Icons.public,
      Icons.connect_without_contact,
      Icons.forum,
      Icons.transcribe,
      Icons.emoji_flags,
      Icons.flag,
      Icons.lock,
      Icons.lock_outline,
      Icons.shield,
      Icons.security,
      Icons.admin_panel_settings,
      Icons.verified_user,
      Icons.settings,
      Icons.tune,
      Icons.manage_accounts,
      Icons.pets,
      Icons.emoji_nature,
      Icons.eco,
      Icons.nature_people,
      Icons.child_friendly,
      Icons.accessibility,
      Icons.diversity_2,
    ];

    return await showModalBottomSheet<IconData>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
            child: GridView.count(
          crossAxisCount: 6,
          padding: const EdgeInsets.all(10),
          children: icons.map((icon) {
            return IconButton(
              icon: Icon(icon, size: 30),
              onPressed: () {
                Navigator.pop(context, icon); // 選んだアイコンを返す
              },
            );
          }).toList(),
        ));
      },
    );
  }
}
