import 'package:flutter/material.dart';
import 'home_page.dart'; // ホーム画面ウィジェットを読み込む

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 仮のログイン処理
  void _login() {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    //認証システムをここに追加
    if (username == 'user' && password == 'password') {
      // ログイン成功時、ユーザー情報を保存し、ホーム画面に遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()), // ログイン後にホーム画面に遷移
      );
    } else {
      // ログイン失敗時にエラーメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ユーザー名またはパスワードが間違っています')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ログイン画面のUI構築
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // アプリバーを透明にして背景を見せる
        title: const Text(
          'ログイン',
          style: TextStyle(
            fontFamily: 'Roboto', // モダンなフォント
            fontSize: 28,
            fontWeight: FontWeight.w600, // 太めのフォントでモダンな印象
            color: Colors.white, // タイトルを白に変更
          ),
        ),
        centerTitle: true,
        elevation: 0, // アプリバーの影を消す
      ),
      backgroundColor: Colors.black, // 背景を黒に設定
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // 横幅の余白を追加
          child: Card(
            color: Colors.black, // カード自体の背景色を黒に設定
            elevation: 10, // 影の深さ
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // 角を丸く
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ユーザー名入力フィールド
                  _buildTextField(
                    controller: _usernameController,
                    label: 'ユーザー名',
                    textColor: Colors.white,
                    labelColor: Colors.white70,
                  ),
                  const SizedBox(height: 16), // 入力フィールド間に余白

                  // パスワード入力フィールド（入力内容が見えないように設定）
                  _buildTextField(
                    controller: _passwordController,
                    label: 'パスワード',
                    obscureText: true,
                    textColor: Colors.white,
                    labelColor: Colors.white70,
                  ),
                  const SizedBox(height: 24), // 入力フィールドとボタンの間に余白

                  // ログインボタン
                  _buildLoginButton(),
                  const SizedBox(height: 16), // ボタンの下に余白
                  _buildForgotPasswordLink(),
                ],
              ),
            ),
          ),
        ),
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
        labelStyle: TextStyle(color: labelColor), // ラベルの色
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // 角を丸く
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white), // フォーカス時のボーダー色を白に変更
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // 内側に余白を追加
      ),
    );
  }

  // ログインボタン
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent, // ボタンの色
        padding: const EdgeInsets.symmetric(vertical: 16), // ボタンの高さを調整
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // ボタンの角を丸く
        ),
        elevation: 5, // ボタンの影
      ),
      child: const SizedBox(
        width: 200, // 幅を200に設定
        child: Text(
          'ログイン',
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

  // パスワードを忘れた場合のリンク
  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: () {
        // パスワードリセットの処理をここに追加
      },
      child: const Text(
        'パスワードを忘れた場合',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
