import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/navigation/page_transitions.dart';
import 'package:cordial/services/database_read.dart';
import 'package:cordial/services/signin.dart';
import 'package:cordial/screens/root_page.dart';
import 'package:cordial/screens/login/reset_password_page.dart';
import 'package:cordial/screens/edit_profile/edit_profile_page.dart';
import 'package:cordial/screens/login/wait_mail_authentication.dart';

// ログイン画面、Googleまたはmailでログインできる
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

      // メールアドレス認証がまだなら認証画面へ
      if(currentUser!.emailVerified == false){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WaitMailAuthentication()),
        );

        return;
      }

      bool isUserName = await DatabaseRead.isUserName();

      // 画面遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => isUserName
                ? const RootPage()
                : const EditProfilePage(disableCloseIcon: true,)), // ログイン後にホーム画面に遷移
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
      } else {
        // ログインできていないなら遷移させない
        return;
      }

      bool isUserName = await DatabaseRead.isUserName();
      // 画面遷移
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => isUserName
                ? const RootPage() // 既にアカウントが存在するならメインページに飛ばす
                : const EditProfilePage(disableCloseIcon: true,)), // ログイン後にホーム画面に遷移
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインに失敗しました')),
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
            fontFamily: 'Roboto', // フォント
            fontWeight: FontWeight.w600, // 太めのフォント
          ),
        ),
        centerTitle: true,
        elevation: 0, // アプリバーの影を消す
      ),
      body: Stack(children: [

        Align(
          alignment: Alignment.center,
          child: Transform.scale(
            scale: 1.5,
            child: Image.asset(
              'assets/icon.png',
              width: 500,
              height: 500,
            ),
          ),
        ),

        LayoutBuilder(
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
                        color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.7),
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // メールアドレス入力欄
                              _buildTextField(
                                controller: _mailController,
                                label: 'メールアドレス',
                                textColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                                labelColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                              ),
                              const SizedBox(height: 16),

                              // パスワード入力欄
                              _buildTextField(
                                controller: _passwordController,
                                label: 'パスワード',
                                obscureText: true,
                                textColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                                labelColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                              ),
                              const SizedBox(height: 24),

                              // ログインボタンと新規作成ボタン
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

                              // パスワードを忘れた際のリンク
                              _buildForgotPasswordLink(),
                              const SizedBox(height: 16),

                              // Googleでのログイン
                              InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: _loginGoogle,
                                child: Ink(
                                  width: 180,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    image: const DecorationImage(
                                      image: AssetImage(
                                          'assets/google_logo.png'),
                                      fit: BoxFit.contain,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(30),
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
      ],),

    );
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
        shadowColor: Colors.black54, // 影の色
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
        PageTransitions.fromRight(
            targetWidget: const ResetPasswordPage(), context: context);
      },
      child: Text(
        'パスワードを忘れた場合',
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.6)),
      ),
    );
  }

  bool _notWaitMakeAccount = true;
  // 新規作成
  Widget _makeAccountLink() {
    return ElevatedButton(
      onPressed: _notWaitMakeAccount ?() async {
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

        setState(() {
          _notWaitMakeAccount = false;
        });

        // アカウントを作成する
        await _createAccount(_mailController.text, _passwordController.text);

        setState(() {
          _notWaitMakeAccount = true;
        });

        //認証画面へ
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WaitMailAuthentication()),
        );
      }:null,
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

  // アカウント登録処理(メールアドレス&パスワード)
  Future _createAccount(String email, String passWord) async {
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

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WaitMailAuthentication()),
        );
      }
    } catch (e) {
      print(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('アカウントの作成に失敗しました。')),
      );
    }
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
              BorderSide(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.6)), // フォーカス時のボーダー色
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 16), // 内側に余白を追加
      ),
    );
  }
}
