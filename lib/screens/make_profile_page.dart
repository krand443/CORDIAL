import 'package:flutter/material.dart';
import '../manager/main_page_MG.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MakeProfilePage extends StatefulWidget {
  const MakeProfilePage({super.key});

  @override
  State<MakeProfilePage> createState() => MakeProfilePageState();
}

class MakeProfilePageState extends State<MakeProfilePage> {
  //画像ピックで保存する変数
  File? _pickImage;

  // ギャラリーから写真を選択
  Future<void> ImagePick() async {
    final ImagePicker _picker = ImagePicker();

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickImage = File(image.path);
      });
    }
  }

  //確定が押されたとき
  void pushEnter() {
    //画面遷移
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const MainPage(selectTab: 1)), //プロフィールに飛ぶ
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary, // アプリバーを透明にして背景を見せる
        title: const Text(
          'プロフィールを作成',
          style: TextStyle(
            fontFamily: 'Roboto', // モダンなフォント
            fontWeight: FontWeight.w600, // 太めのフォントでモダンな印象
            color: Colors.black, // タイトルを白に変更
          ),
        ),
        centerTitle: true,
        elevation: 0, // アプリバーの影を消す
      ),
      backgroundColor: Colors.white, // 背景
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              pushEnter();
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: _controller.text.isNotEmpty
                                ? Theme.of(context).colorScheme.inversePrimary
                                : Colors.grey, // ← 背景色
                            foregroundColor: Colors.white, // ← テキスト色
                            textStyle: const TextStyle(
                              fontSize: 18, // ← フォントサイズを指定
                            ),
                          ),
                          child: const Text('完了→'),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                        child: Stack(children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundImage: _pickImage != null
                                ? FileImage(_pickImage!)
                                : const AssetImage('assets/user_default_icon.png')
                                    as ImageProvider,
                          ),
                          //編集ボタン
                          GestureDetector(
                            onTap: ImagePick,
                            child: const CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  AssetImage('assets/edit_icon.png'),
                            ),
                          ),
                        ]),
                      ),
                      TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        autofocus: true,
                        // ← ウィジェット表示時に自動でフォーカス
                        keyboardType: TextInputType.multiline,
                        maxLength: 20,
                        // ← ここで文字数を制限
                        style: const TextStyle(
                          fontSize: 20, // ← ここで文字サイズを変更
                        ),
                        decoration: const InputDecoration(
                          // 入力欄に表示するヒントメッセージを生成
                          hintText: "ユーザー名を入力",
                          contentPadding: EdgeInsets.only(top: 30),
                          //上に余白追加して表示位置を下げる
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
