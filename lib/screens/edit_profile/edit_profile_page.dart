import 'package:cordial/widgets/icon.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../root_page.dart';
import 'dart:io';
import 'package:cordial/services/firestore_storage.dart';
import 'package:cordial/services/database_write.dart';
import 'package:cordial/screens/edit_profile/select_background_page.dart';

// プロフィール編集画面
class EditProfilePage extends StatefulWidget {
  final bool? disableCloseIcon;

  //　既存のユーザー名を受けとる(なくても可)
  final String? existingName;

  // 既存の背景(なくても可)
  final String? backgroundPath;

  const EditProfilePage({super.key, this.existingName, this.backgroundPath, this.disableCloseIcon = false});

  @override
  State<EditProfilePage> createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  // 未入力を確認するためのコントローラー
  final TextEditingController _textController = TextEditingController();

  // 背景画像ファイル名を格納しておく
  String _backgroundPath = 'assets/background/00001.jpg';

  @override
  void initState() {
    super.initState();

    // 既存のユーザー名を格納
    if (widget.existingName != null) {
      _textController.text = widget.existingName!;
    }

    // 既存の背景を格納
    if (widget.backgroundPath != null) {
      _backgroundPath = widget.backgroundPath!;
    }

    _textController.addListener(() {
      setState(() {}); // 入力変更で再描画
    });
  }

  // 画像ピックで保存する変数
  File? _pickImage;

  // 完了ボタンを押したらtrueになる。
  bool _waitForUpload = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _appbar(),
      body: SingleChildScrollView(
        //キーボード表示で画面が崩れないようスクロールにする
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [

                  //　背景画像
                  Container(
                    padding: const EdgeInsets.only(bottom: 30),
                    height: 250,
                    child: Ink.image(
                      image: AssetImage(_backgroundPath), // 背景画像
                      fit: BoxFit.cover,
                      child: InkWell(
                        // InkWellでタップジェスチャーと波紋を処理
                        onTap: () async {
                          // 背景画像選択画面へ
                          String? selectedBackground = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SelectBackgroundPage()),
                          );
                          if (selectedBackground == null) return;

                          setState(() {
                            // 背景画像を変更
                            _backgroundPath = selectedBackground;
                          });
                        },
                        child: Container(), // 波紋を表示するための透明なコンテナ
                      ),
                    ),
                  ),

                  // 完了アイコン
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 0, top: 10),
                      child: _applyButton(),
                    ),
                  ),

                  Positioned(left: 10.0, bottom: 5.0, child: _iconPreview()),
                ],
              ),

              // ユーザ名入力フォーム
              TextField(
                controller: _textController,
                textAlign: TextAlign.left,
                autofocus: true,
                // ウィジェット表示時に自動でフォーカス
                keyboardType: TextInputType.multiline,
                maxLength: 20,
                // ここで文字数を制限
                style: const TextStyle(
                  fontSize: 20, // ここで文字サイズを変更
                ),
                decoration: const InputDecoration(
                  hintText: "ユーザー名を入力",
                  contentPadding: EdgeInsets.only(left: 20, right: 20),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      // アプリバーの色
      automaticallyImplyLeading: false,
      // 戻るアイコン
      leading: widget.disableCloseIcon == false ? IconButton(
        padding: const EdgeInsets.only(top: 0),
        icon: const Icon(
          Icons.close,
          size: 30,
          color: Colors.grey,
        ),
        onPressed: () {
          Navigator.of(context).pop(); // 現在の画面を閉じる
        },
      ) : null,
      title: const Text(
        'プロフィールを作成',
        style: TextStyle(
          fontFamily: 'Roboto', // モダンなフォント
          fontWeight: FontWeight.w600, // 太めのフォントでモダンな印象
        ),
      ),
      centerTitle: true,
      elevation: 0, // アプリバーの影を消す
    );
  }

  Widget _iconPreview() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3), // 影の色と透明度
            blurRadius: 10, // ぼかしの半径
            offset: const Offset(4, 4),
          ),
        ],
      ),

      // アイコンのプレビュー表示
      child: InkResponse(
        onTap: _imagePick,
        child: Stack(
          children: [
            _pickImage == null
                ? const UserIcon(size: 70)
                : CircleAvatar(
                    radius: 70,
                    backgroundImage: FileImage(_pickImage!),
                  ),
            const CircleAvatar(
              radius: 70,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage('assets/edit_icon.png'),
            ),
          ],
        ),
      ),
    );
  }

  // ギャラリーから写真を選択
  Future<void> _imagePick() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickImage = File(image.path);
      });
    }
  }

  // 確定ボタン
  Widget _applyButton() {
    return Stack(children: [
      Material(
        color: Colors.transparent, // 背景は透明にする（Containerに任せる）
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.zero,
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.zero,
        ),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 2,
                offset: Offset(2, 2),
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.zero,
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.zero,
            ),
          ),
          child: TextButton(
            onPressed: () {
              if (_textController.text.isNotEmpty && !_waitForUpload) {
                _pushEnter();
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: _textController.text.isEmpty || _waitForUpload
                  ? Colors.grey
                  : Theme.of(context).colorScheme.tertiaryContainer,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              textStyle: const TextStyle(fontSize: 18),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.zero,
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.zero,
                ),
              ),
            ),
            child: const Text('完了→'),
          ),
        ),
      ),

      // アップロード待ちなら読み込みアニメーションを表示
      if (_waitForUpload)
        const CircularProgressIndicator(
          padding: EdgeInsets.only(left: 20, top: 5),
          color: Colors.blue,
        )
    ]);
  }

  // 確定が押されたとき
  void _pushEnter() async {
    _waitForUpload = true;
    setState(() {}); // 画面更新

    // 画像を追加(任意)
    try {
      await FirestoreStorage.upload(_pickImage!, "icon");
    } catch (e) {
      print(e);
    }

    // ユーザー情報を変更
    await DatabaseWrite.setUser(_textController.text, _backgroundPath);

    // プロフィール画面へ遷移
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const RootPage(selectTab: 1)),
      (route) => false,
    );
  }
}
