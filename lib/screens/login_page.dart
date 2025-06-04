import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controller/main_page_MG.dart';
import 'package:cordial/function/signin.dart';
import '../function/database_write.dart';
import '../function/database_read.dart';
import 'edit_profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // メールでログイン処理
  Future<void> _login() async {
    // 両方のTextを取得
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    try {
      // メール/パスワードでログイン
      await SignIn.mail(username, password);
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null)
        print("ログインしました　${currentUser.email} , ${currentUser.uid}");

      bool isUserName = await DatabaseRead.isUserName();

      // 画面遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => isUserName ? const MainPage() : MakeProfilePage()), // ログイン後にホーム画面に遷移
      );
    } catch (e) {
      print(e);
      // ログイン失敗時にエラーメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ユーザー名またはパスワードが間違っています')),
      );
    }
  }

  // Googleでサインイン
  Future<void> _loginGoogle() async {
    try {
      // googleアカウントを使用してサインイン
      await SignIn.google();

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null)
        print("ログインしました　${currentUser.email} , ${currentUser.uid}");

      bool isUserName = await DatabaseRead.isUserName();
      // 画面遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => isUserName ? const MainPage() : MakeProfilePage()), // ログイン後にホーム画面に遷移
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインに失敗しました')),
      );
    }
  }

  // パスワードを忘れた場合のリンク
  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: () {
        // パスワードリセットの処理をここに追加
      },
      child: const Text(
        'パスワードを忘れた場合',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ログイン画面のUI構築
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary, // アプリバーを透明にして背景を見せる
        title: const Text(
          'ログイン',
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      color: Colors.white,
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
                              controller: _usernameController,
                              label: 'ユーザー名',
                              textColor: Colors.black,
                              labelColor: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'パスワード',
                              obscureText: true,
                              textColor: Colors.black,
                              labelColor: Colors.grey,
                            ),
                            const SizedBox(height: 24),
                            _buildLoginButton(),
                            _buildForgotPasswordLink(),
                            const SizedBox(height: 16),
                            InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: _loginGoogle,
                              child: Ink(
                                width: 180,
                                height: 42,
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage('assets/google_logo.png'),
                                    fit: BoxFit.contain,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
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

  // ログインボタン
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // ボタンの色
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
}
