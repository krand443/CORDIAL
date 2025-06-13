import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// 引数の情報を使用し、サインインするクラス
class SignIn
{
  static final GoogleSignIn? _googleSignIn = GoogleSignIn(scopes: [
    // Google Calendarの情報を操作するには、ここに範囲を記載する
    // https:// www.googleapis.com/auth/calendar.readonly,
    // https:// www.googleapis.com/auth/calendar.events,
  ]);

  // FirebaseAuthインスタンスを取得
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // メールでログイン
  static Future<void> mail(String username,String password) async
  {
    await _auth.signInWithEmailAndPassword(email: username, password: password);

  }

  // googleアカウントを利用したログイン
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

      return 0;

    } catch (e) {
      print("Error during Google Sign In: $e");
      return 1;
    }
  }
}