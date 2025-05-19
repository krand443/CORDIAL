import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordial/function/imageMG.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:cordial/struct/profile.dart';

class Database {

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
      // ドキュメント作成
      await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(FirebaseAuth.instance.currentUser?.uid) // ドキュメントID
          .set({
            'name': name,
            'iconUrl': icon ?? null,
            'nationality': locale.countryCode,//日本ならJP
          });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('profile')
          .doc('profile')
          .set({
            'lastAction': FieldValue.serverTimestamp(), //サーバー側の時刻セット
          },SetOptions(merge: true)); //他のフィールドはそのまま残す
    }
    catch(e) {
      print(e);
    }
  }

  //投稿するための関数
  static Future<void> addPost(String text) async {
  /*
  /posts/{postId}                          //例:post001
  ├── postedAt: Timestamp
  ├── userid: String                       //投稿者ID
  ├── text: String                         //本文
  ├── response: String                     //AIからの返信
  ├── nice: int
   */
    try{
      await FirebaseFirestore.instance
          .collection('posts')
          .doc()
          .set({
            'PostedAt':FieldValue.serverTimestamp(),
            'userid':FirebaseAuth.instance.currentUser?.uid,
            'text':text,
            'response' : "EXSAMPLE()",
            'nice': 0
          });
    }
    catch(e)
    {
      print(e);
    }
  }

  //プロフィールを取得
  static Future<Profile?> profile(String userid) async{
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
    try{
      var result = await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(userid)
          .get();
      var data = result.data();

      var resultDeep = await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(userid)
          .collection('profile')
          .doc('profile')
          .get();
      var dataDeep = resultDeep.data();

      return Profile(
          name: data?['name'] ?? 'null',
          iconUrl: data?['iconUrl'] ?? 'null',
          introduction: dataDeep?['introduction'] ?? 'null',
          followCount: dataDeep?['followCount'] ?? 0,
          followerCount: dataDeep?['followerCount'] ?? 0
      );
    }
    catch(e)
    {
      print(e);
      return null;
    }
  }

  //ユーザー名を取得する
  static Future<String?> myUserName() async{
    try{
      var result = await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(); //ドキュメントID

      var data = result.data();

      return data?['name'];
    }
    catch(e)
    {
      return null;
    }
  }

  //アイコンのURLをDBから返す
  static Future<String?> iconUrl() async{
    try{
      var result = await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(const GetOptions(source: Source.cache)); //ドキュメントID

      var data = result.data();

      return data?['iconUrl'];
    }
    catch(e){
      return null;
    }
  }

  //ユーザー名が存在しているかを確認する
  static Future<bool> isUserName() async {
    try{
      var result = await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(); //ドキュメントID

      var data = result.data();

      //nullならfalse
      bool isUser = data?['name'] != null ? true : false;

      return isUser;
    }
    catch(e)
    {
      return false;
    }
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
        ├── RepliedAt: Timestamp
        ├── userid: String               //リプライ投稿者ID
        ├── text: String
        ├── nice: int
        └── /niceList
            └── {userId}: {}             //リプライにいいねしたユーザー

 */