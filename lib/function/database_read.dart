import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordial/function/imageMG.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:cordial/models/profile.dart';
import 'package:cordial/models/post.dart';
import 'package:cordial/models/timeline.dart';
import 'package:http/http.dart';

class DatabaseRead {
  //タイムラインを取得<以前の最後のドキュメントを参照し返す>
  static Future<Timeline?> timeline([DocumentSnapshot? lastVisible,String? userId]) async {
    /*
    /posts/{postId}                          //例:post001
    ├── postedAt: Timestamp
    ├── userid: String                       //投稿者ID
    ├── text: String                         //本文
    ├── response: String                     //AIからの返信
    ├── nice: int
    ├── /niceList
    │   └── {userId}: {}                     //いいねしたユーザー
     */
    try {
      //ポスト時間でソート
      var query = FirebaseFirestore.instance
          .collection('posts') // コレクションID
          .orderBy('postedAt', descending: true);

      //ドキュメントが渡されていたらその次のドキュメントから取得する
      if (lastVisible != null) {
        query = query.startAfterDocument(lastVisible);
      }

      //ユーザーIDが渡されてるならそのユーザーで絞り込む
      if (userId != null) {
        query = query.where('userid', isEqualTo: userId);
      }

      //タイムラインを取得
      final result = await query.limit(10).get();

      if (result.docs.isEmpty) {
        return null;
      }

      //取得したドキュメントをリストList<Post>にするためのデータ取得(並列実行)
      final futures = result.docs.map((doc) async {
        final postId = doc.id;
        final userId = doc['userid'];

        final niceFuture = FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('niceList')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

        final userFuture =
            FirebaseFirestore.instance.collection('users').doc(userId).get();

        //二つの要素を待つ
        final results = await Future.wait([niceFuture, userFuture]);

        return Post(
          postedAt: (doc['postedAt'] as Timestamp).toDate().toString(),
          id: postId,
          userId: userId,
          userName: results[1]['name'],
          iconUrl: results[1]['iconUrl'],
          postText: doc['text'],
          response: doc['response'],
          nice: doc['nice'],
          isNice: results[0].exists,
        );
      }).toList();

      //取得を待つ
      final posts = await Future.wait(futures);

      //タイムラインを最後のDocumentSnapshotと返す。
      return Timeline(posts: posts, lastVisible: result.docs.last);
    } catch (e) {
      print("えらーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー");
      print(e);
    }

    return null;
  }

  //プロフィールを取得
  static Future<Profile?> profile(String userid) async {
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
    try {
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
          followerCount: dataDeep?['followerCount'] ?? 0);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //アイコンのURLをDBから返す
  static Future<String?> iconUrl([String? userid]) async {
    try {
      var result = await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(userid ?? FirebaseAuth.instance.currentUser?.uid)
          .get(const GetOptions(source: Source.cache)); //ドキュメントID

      var data = result.data();

      return data?['iconUrl'];
    } catch (e) {
      return null;
    }
  }

  //ユーザー名が存在しているかを確認する
  static Future<bool> isUserName() async {
    try {
      var result = await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(); //ドキュメントID

      var data = result.data();

      //nullならfalse
      bool isUser = data?['name'] != null ? true : false;

      return isUser;
    } catch (e) {
      return false;
    }
  }

  //ユーザー名を取得する
  static Future<String?> myUserName() async {
    try {
      var result = await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(); //ドキュメントID

      var data = result.data();

      return data?['name'];
    } catch (e) {
      return null;
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
