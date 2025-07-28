import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cordial/screens/edit_profile/edit_profile_page.dart';

class WaitMailAuthentication extends StatefulWidget {
  const WaitMailAuthentication({super.key});

  @override
  State<WaitMailAuthentication> createState() => _WaitMailAuthenticationState();
}

class _WaitMailAuthenticationState extends State<WaitMailAuthentication> {
  bool canResend = false;
  int remainingSeconds = 30;
  Timer? _cooldownTimer,_checkVerifiedTimer;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();

    // 認証用メールを送信
    FirebaseAuth.instance.currentUser!.sendEmailVerification();

    _startCooldown();

    // 一定時間ごとに認証確認
    _checkVerifiedTimer = Timer.periodic(const Duration(seconds: 1), (_) => checkEmailVerified());
  }

  @override
  void dispose() {
    // Widgetが削除されるときにタイマーをキャンセル
    _cooldownTimer?.cancel();
    _checkVerifiedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // アプリバーを透明にして背景を見せる
        title: const Text(
          'メール認証',
          style: TextStyle(
            fontFamily: 'Roboto', // モダンなフォント
            fontWeight: FontWeight.w600, // 太めのフォントでモダンな印象
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
        Center(child: Card(
          color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.6),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '認証用メールを送信しました。\nメールを確認してください。\n(認証終了後自動で画面遷移します)',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.tertiary),
                ),
                const SizedBox(height: 24),
                _resetButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),),
      ]),
    );
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload(); // 最新状態を取得
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      _checkVerifiedTimer?.cancel(); // タイマーを止める
      setState(() {
        isVerified = true;
      });

      // 認証されたのでログイン状態へ遷移
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EditProfilePage(disableCloseIcon: true)),
      );
    }
  }

  // リセットボタン
  Widget _resetButton() {
    return ElevatedButton(
      onPressed: canResend ? () {
        _sendVerificationEmail();
      }:null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // ボタンの色
        padding: const EdgeInsets.symmetric(vertical: 16), // ボタンの高さを調整
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // ボタンの角を丸く
        ),
        elevation: 5, // ボタンの影
      ),
      child: SizedBox(
        width: 200, // 幅を200に設定
        child: Text(
          'メールを再送($remainingSeconds)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white, // テキストの色を白に設定
          ),
          textAlign: TextAlign.center, // テキストを中央揃え
        ),
      ),
    );
  }

  void _sendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && canResend) {
      try {
        await user.sendEmailVerification();
        setState(() {
          canResend = false;
          remainingSeconds = 30;
        });
        _startCooldown();
      } catch (e) {
        print("送信エラー: $e");
        // エラーハンドリングを追加
      }
    }
  }
  void _startCooldown() {
    _cooldownTimer?.cancel(); // 古いタイマーがあればキャンセル
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds == 0) {
        setState(() {
          canResend = true;
        });
        _cooldownTimer?.cancel();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }
}
