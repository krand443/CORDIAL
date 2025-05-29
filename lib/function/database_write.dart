import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordial/function/imageMG.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:cordial/models/profile.dart';
import 'package:http/http.dart' as http;

class DatabaseWrite {
  //ユーザーを追加
  static Future<void> addUser(String name) async {
    /*
    /users/{userId}                          //例:user001
    ├── name: String                         //田中太郎
    ├── iconUrl: String (URL)
    ├── nationality: String                  //Japan
    ├── /profile
    │   ├── introduction: String             //自己紹介(100文字程度)
    │   ├── lastAction: Timestamp
    │   ├── followCount: int
    │   └── followerCount: int
     */

    //アイコンURLを取得
    final icon = await ImageMG.myIcon();

    //端末の国・言語を取得
    final locale = PlatformDispatcher.instance.locale;

    try {
      //ドキュメント作成
      await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(FirebaseAuth.instance.currentUser?.uid) //ドキュメントID
          .set({
        'name': name,
        'iconUrl': icon ?? null,
        'nationality': locale.countryCode, //日本ならJP
      });
      //ラストアクション時間を保存
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('profile')
          .doc('profile')
          .set({
        'lastAction': FieldValue.serverTimestamp(), //サーバー側の時刻セット
      }, SetOptions(merge: true)); //他のフィールドはそのまま残す
    } catch (e) {
      print(e);
    }
  }

  //投稿するための関数
  static Future<void> addPost(String text) async {
    /*
      await FirebaseFirestore.instance
          .collection('posts')
          .doc()
          .set({
            'postedAt':FieldValue.serverTimestamp(),
            'userid':FirebaseAuth.instance.currentUser?.uid,
            'text':text,
            'response' : "EXAMPLE()",
            'nice': 0
          });
       */

    //firebaseFunctionを使用して投稿をDBに入れると同時にAIからの返答も受け取る
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    final uri = Uri.parse(
      'https://asia-northeast1-projectcordial-596bd.cloudfunctions.net/postMessage',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer:$idToken', //ユーザーのトークンで認証
      },
      body: jsonEncode({
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      print("成功: ${response.body}");
    } else {
      print("エラー (${response.statusCode}): ${response.body}");
    }
  }

  //返信を投稿する
  static Future<void> addReply(String postId, String text) async {
    await FirebaseFirestore.instance
        .collection('posts') // コレクションID
        .doc(postId)
        .collection('replies')
        .doc()
        .set({
      'repliedAt': FieldValue.serverTimestamp(),
      'userid': FirebaseAuth.instance.currentUser?.uid,
      'text': text,
      'nice': 0,
    });
  }
}

/*////////////////////以下firebaseDB全体構造/////////////////////////////////

/users/{userId}                          //例:user001
├── name: String                         //田中太郎
├── iconUrl: String (URL)
├── nationality: String                  //Japan
├── /profile
│   ├── introduction: String             //自己紹介(100文字程度)
│   ├── lastAction: Timestamp
│   ├── followCount: int
│   └── followerCount: int
├── /hidden
│   └── {hiddenUserId}: {}               //非表示ユーザーリスト
├── /follows
│   ├─── {followsUserId}                //フォローしているユーザーのID
│       ├── followedAt: Timestamp
│       └── notify: boolean             //通知の切り替え
├─── /followers
    ├─── {followerUserId}               //フォロワーのユーザーID
        └── followedAt: Timestamp


/posts/{postId}                          //例:post001
├── postedAt: Timestamp
├── userid: String                       //投稿者ID
├── text: String                         //本文
├── response: String                     //AIからの返信
├── nice: int
├── /niceList
│   └── {userId}: {}                     //いいねしたユーザー
├─── /replies
    ├─── {replyId}                       //reply001
        ├── repliedAt: Timestamp
        ├── userid: String               //リプライ投稿者ID
        ├── text: String
        ├── nice: int
        └── /niceList
            └── {userId}: {}             //リプライにいいねしたユーザー

 */
