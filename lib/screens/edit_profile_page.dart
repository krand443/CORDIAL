import 'package:cordial/widgets/icon.dart';
import 'package:flutter/material.dart';
import 'root_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cordial/function/firestore_storage.dart';
import 'package:cordial/function/database_write.dart';
import 'package:cordial/function/database_read.dart';

class EditProfilePage extends StatefulWidget {

  //　既存の名前を受けとる(なくても可)
  final String? existingName;

  const EditProfilePage({super.key, this.existingName});

  @override
  State<EditProfilePage> createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  // 未入力を確認するためのコントローラー
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 既存のユーザー名を格納
    if(widget.existingName != null) {
      _textController.text = widget.existingName!;
    }
    _textController.addListener(() {
      setState(() {}); // 入力変更で再描画
    });
  }

  // 画像ピックで保存する変数
  File? _pickImage;

  // ギャラリーから写真を選択
  Future<void> imagePick() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickImage = File(image.path);
      });
    }
  }

  // デフォルトのアイコン
  AssetImage defaultIcon = const AssetImage("assets/user_default_icon.png");

  // 完了ボタンを押したらtrueになる。
  bool waitForUpload = false;

  // 確定が押されたとき
  void pushEnter() async {
    waitForUpload = true;
    setState(() {});// 画面更新

    // 画像を追加(任意)
    try {
      await Firestore.upload(_pickImage!, "icon");
    } catch (e) {
      print(e);
    }

    // ユーザーを追加
    await DatabaseWrite.addUser(_textController.text);

    // 画面遷移
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const RootPage(selectTab: 1)), // プロフィールに飛ぶ
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor:Colors.transparent,// アプリバーの色
        automaticallyImplyLeading: false, // 戻るアイコンを非表示にする
        title: const Text(
          'プロフィールを作成',
          style: TextStyle(
            fontFamily: 'Roboto', // モダンなフォント
            fontWeight: FontWeight.w600, // 太めのフォントでモダンな印象
          ),
        ),
        centerTitle: true,
        elevation: 0, // アプリバーの影を消す
      ),
      body: LayoutBuilder(
        // 画面全体の制約（最大幅・最大高さ）を取得するために使用
        builder: (context, constraints) {
          return SingleChildScrollView(
            //キーボード表示で画面が崩れないようスクロールにする
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              // 親からもらえる最大の高さで表示
              child: IntrinsicHeight(
                //表示位置を上に寄せる
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // 完了ボタン
                      Align(
                        alignment: Alignment.centerRight,
                        child: Stack(children: [
                          TextButton(
                            onPressed: () {
                              if (_textController.text.isNotEmpty && !waitForUpload) {
                                pushEnter();
                              }
                            },
                            style: TextButton.styleFrom(
                              // テキストが入力されていないかアップロード待ちなら灰色表示する
                              backgroundColor: _textController.text.isEmpty || waitForUpload
                                  ? Colors.grey
                                  : Theme.of(context).colorScheme.tertiaryContainer, // 背景色
                              foregroundColor: Colors.black, // テキスト色
                              textStyle: const TextStyle(
                                fontSize: 18, // フォントサイズを指定
                              ),
                            ),
                            child: const Text('完了→'),
                          ),

                          // アップロード待ちなら読み込みアニメーションを表示
                          if(waitForUpload)
                            const CircularProgressIndicator(
                            padding: EdgeInsets.only(left: 20,top: 5),
                            color: Colors.blue,
                          )
                        ]),
                      ),

                      const SizedBox(height: 10),

                      // アイコンを表示
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .inversePrimary, // 枠線の色
                            width: 5, // 枠線の太さ
                          ),
                        ),

                        // アイコンのプレビュー表示
                        child: InkResponse(
                          onTap: imagePick,
                          child: Stack(
                            children: [
                              _pickImage == null
                                  ? UserIcon(size: 70)
                                  : CircleAvatar(
                                      radius: 70,
                                      backgroundImage: FileImage(_pickImage!),
                                    ),
                              const CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.transparent,
                                backgroundImage:
                                    AssetImage('assets/edit_icon.png'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ユーザ名入力フォーム
                      TextField(
                        controller: _textController,
                        textAlign: TextAlign.center,
                        autofocus: true,
                        // ウィジェット表示時に自動でフォーカス
                        keyboardType: TextInputType.multiline,
                        maxLength: 20,
                        // ここで文字数を制限
                        style: const TextStyle(
                          fontSize: 20, // ここで文字サイズを変更
                        ),
                        decoration: const InputDecoration(
                          // 入力欄に表示するヒントメッセージを生成
                          hintText: "ユーザー名を入力",
                          contentPadding: EdgeInsets.only(top: 30),
                          // 上に余白追加して表示位置を下げる
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
