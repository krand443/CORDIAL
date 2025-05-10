import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn
{
  // ログインしたユーザー情報を保持する変数
  static User? _user;
  static User? get currentUser => _user;//外部読み取り用

  static final GoogleSignIn? _googleSignIn = GoogleSignIn(scopes: [
    // 例えば、Google Calendarの情報を操作するには、ここに範囲を記載する
    // https://www.googleapis.com/auth/calendar.readonly,
    // https://www.googleapis.com/auth/calendar.events,
  ]);

  // FirebaseAuthインスタンスを取得
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  //メールでログイン
  static Future<void> mail(String username,String password) async
  {
    _user = (await _auth.signInWithEmailAndPassword(email: username, password: password)).user;

  }

  //googleアカウントを利用したログイン
  static Future<int> google() async
  {
    try {
      // Googleサインインを実行
      final GoogleSignInAccount? googleUser = await _googleSignIn?.signIn();
      if (googleUser == null) {
        // キャンセルされた場合はnullを返す
        return 1;
      }

      // Googleの認証情報を取得
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase用の資格情報を作成
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebaseに認証情報を登録
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      return 0;

    } catch (e) {
      print("Error during Google Sign In: $e");
      return 1;
    }
  }


}