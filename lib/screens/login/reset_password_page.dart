import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../root_page.dart';
import 'package:cordial/function/signin.dart';
import '../../function/database_write.dart';
import '../../function/database_read.dart';
import '../edit_profile_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _mailController = TextEditingController();

  // パスワード再設定用関数
  Future resetPassword(String email) async {
    try {
      // 再設定用メールを送信
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('パスワード再設定用メールを送信しました！')),
      );

      // 画面を閉じる
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('アカウントが存在しません。')),
      );
    }
  }

  // リセットボタン
  Widget _resetButton() {
    return ElevatedButton(
      onPressed: (){
        // メールアドレスかパスワードが入力されていないなら
        if (_mailController.text == "") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('メールアドレスが入力されていません。')),
          );
          return;
        }

        // メールアドレスの形式があってるか確かめる
        if (!EmailValidator.validate(_mailController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('メールアドレスの形式が間違っています。')),
          );
          return;
        }

        resetPassword(_mailController.text);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // ボタンの色
        padding: const EdgeInsets.symmetric(vertical: 16), // ボタンの高さを調整
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // ボタンの角を丸く
        ),
        elevation: 5, // ボタンの影
      ),
      child: const SizedBox(
        width: 200, // 幅を200に設定
        child: Text(
          '再設定メールを送信',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white, // テキストの色を白に設定
          ),
          textAlign: TextAlign.center, // テキストを中央揃え
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ログイン画面のUI構築
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // アプリバーを透明にして背景を見せる
        title: const Text(
          'パスワード再設定',
          style: TextStyle(
            fontFamily: 'Roboto', // モダンなフォント
            fontWeight: FontWeight.w600, // 太めのフォントでモダンな印象
          ),
        ),
        centerTitle: true,
        elevation: 0, // アプリバーの影を消す
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTextField(
                              controller: _mailController,
                              label: 'メールアドレス',
                              textColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              labelColor: Colors.grey,
                            ),
                            const SizedBox(height: 24),
                            _resetButton(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 入力フィールドのスタイル
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    required Color textColor,
    required Color labelColor,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(fontSize: 16, color: textColor), // 文字色を指定
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        // ラベルの色
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // 角を丸く
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.white), // フォーカス時のボーダー色を白に変更
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 16), // 内側に余白を追加
      ),
    );
  }
}
