import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../root_page.dart';
import 'package:cordial/services/signin.dart';
import 'package:cordial/screens/login/reset_password_page.dart';
import 'package:cordial/navigation/page_transitions.dart';
import '../../services/database_read.dart';
import '../edit_profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // メールでログイン処理
  Future<void> _login() async {
    // 両方のTextを取得
    final String username = _mailController.text;
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
            builder: (context) => isUserName
                ? const RootPage()
                : const EditProfilePage()), // ログイン後にホーム画面に遷移
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
      if (currentUser != null) {
        print("ログインしました　${currentUser.email} , ${currentUser.uid}");
      }
      else{
        // ログインできていないなら遷移させない
        return;
      }

      bool isUserName = await DatabaseRead.isUserName();
      // 画面遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => isUserName
                ? const RootPage() // 既にアカウントが存在するならメインページに飛ばす
                : const EditProfilePage()), // ログイン後にホーム画面に遷移
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインに失敗しました')),
      );
    }
  }

  // アカウント登録処理(メールアドレス&パスワード)
  Future createAccount(String email, String passWord) async {
    try {
      // アカウント登録
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: passWord,
      );

      // 認証メールを送信
      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('認証メールを送信しました。メールを確認してください。')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('アカウントの作成に失敗しました。')),
      );
    }
  }

  // ログインボタン
  Widget _loginButton() {
    return ElevatedButton(
      onPressed: _login,
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

  // パスワードを忘れた場合のボタン
  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: () {
        PageTransitions.fromBottom(targetWidget: const ResetPasswordPage(), context: context);
      },
      child: const Text(
        'パスワードを忘れた場合',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  // 新規作成
  Widget _makeAccountLink() {
    return ElevatedButton(
      onPressed: () {
        // メールアドレスかパスワードが入力されていないなら
        if (_mailController.text == "" || _passwordController.text == "") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('メールアドレスまたはパスワードが入力されていません。')),
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

        // アカウントを作成する
        createAccount(_mailController.text, _passwordController.text);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // ボタンの色
        padding: const EdgeInsets.symmetric(vertical: 13), // ボタンの高さを調整
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // ボタンの角を丸く
        ),
        elevation: 5, // ボタンの影
      ),
      child: const SizedBox(
        child: Text(
          '新規作成',
          style: TextStyle(
            fontSize: 13,
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
          'ログイン',
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
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'パスワード',
                              obscureText: true,
                              textColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              labelColor: Colors.grey,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _loginButton(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: _makeAccountLink(),
                                ),
                              ],
                            ),
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
}
