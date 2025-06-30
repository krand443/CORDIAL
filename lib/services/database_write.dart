import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordial/services/firestore_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;

// ==========================
// DatabaseWrite - 関数一覧
// ==========================
//
// ・setUser(name)                     - ユーザー初期登録（名前、国情報、アイコン）
// ・addPost(text, selectedAiId)       - 投稿作成（AIへの問い合わせ付き）
// ・addReply(postId, text)            - リプライ投稿
// ・nice(postId, {parentId})          - いいね追加（投稿・返信）
// ・unNice(postId, {parentId})        - いいね削除
// ・follow(followeeId)                - ユーザーをフォロー
// ・unFollow(followeeId)              - ユーザーのフォロー解除


class DatabaseWrite {
  // ユーザーを追加
  static Future<void> setUser(String name) async {
    /*
    /users/{userId}                          // 例:user001
    ├── name: String                         // 田中太郎
    ├── iconUrl: String (URL)
    ├── nationality: String                  // Japan
    ├── /profile
    │   ├── introduction: String             // 自己紹介(100文字程度)
    │   ├── lastAction: Timestamp
    │   ├── followCount: int
    │   └── followerCount: int
     */

    // アイコンURLを取得
    final icon = await FirestoreStorage.myIcon();

    // 端末の国・言語を取得
    final locale = PlatformDispatcher.instance.locale;

    try {
      // ドキュメント作成
      await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(FirebaseAuth.instance.currentUser?.uid) // ドキュメントID
          .set({
        'name': name,
        'iconUrl': icon ?? null,
        'nationality': locale.countryCode, // 日本ならJP
      });
      // ラストアクション時間を保存
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('profile')
          .doc('profile')
          .set({
        'lastAction': FieldValue.serverTimestamp(), // サーバー側の時刻セット
      }, SetOptions(merge: true)); // 他のフィールドはそのまま残す
    } catch (e) {
      print(e);
    }
  }

  // 投稿するための関数
  static Future<void> addPost(String text,int selectedAiId) async {
    /*
      await FirebaseFirestore.instance
          .collection('posts')
          .doc()
          .set({
            'postedAt':FieldValue.serverTimestamp(),
            'userid':FirebaseAuth.instance.currentUser?.uid,
            'text':text,
            'selectedAiId':int
            'response' : "EXAMPLE()",
            'nice': 0
          });
       */

    // firebaseFunctionを使用して投稿をDBに入れると同時にAIからの返答も受け取る
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    final uri = Uri.parse(
      'https://asia-northeast1-projectcordial-596bd.cloudfunctions.net/postMessage',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer:$idToken', // ユーザーのトークンで認証
      },
      body: jsonEncode({
        'text': text,
        'selectedAiId': selectedAiId,
      }),
    );

    if (response.statusCode == 200) {
      print("成功: ${response.body}");
    } else {
      print("エラー (${response.statusCode}): ${response.body}");
    }
  }

  // 返信を投稿する
  static Future<void> addReply(String postId, String text) async {
    await FirebaseFirestore.instance
        .collection('posts') // コレクションID
        .doc(postId)
        .collection('replies')
        .doc()
        .set({
      'repliedAt': FieldValue.serverTimestamp(),
      'userid': FirebaseAuth.instance.currentUser!.uid,
      'text': text,
      'nice': 0,
    });
  }

  // いいねを追加
  static Future<void> nice(String postId, {String? parentId}) async {
    /*
    /posts/{postId}                          // 例:post001
           ├── postedAt: Timestamp
           ├── userid: String                       // 投稿者ID
           ├── text: String                         // 本文
           ├── response: String                     // AIからの返信
           ├── nice: int
           ├── /niceList
           │   └── {userId}: {}
           ├─── /replies
                ├─── {replyId}                       // reply001
                      ├── repliedAt: Timestamp
                      ├── userid: String               // リプライ投稿者ID
                      ├── text: String
                      ├── nice: int
                      └── /niceList
                          └── {userId}: {}             // リプライにいいねしたユーザー
    */

    // ドキュメント参照用
    DocumentReference postDocRef;

    // 親Idが送られてるなら返信用
    if (parentId != null) {
      postDocRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(parentId)
          .collection('replies')
          .doc(postId);
    } else {
      postDocRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    }

    try {
      await FirebaseFirestore.instance.runTransaction(
        (transaction) async {

          // 既にいいねをしていないか確認
          final docRef = postDocRef
              .collection('niceList')
              .doc(FirebaseAuth.instance.currentUser!.uid);
          final snapshot = await transaction.get(docRef);
          if (snapshot.exists) {
            throw Exception('ドキュメントはすでに存在しています。');
          }

          // niceListに追加
          transaction.set(
            postDocRef
                .collection('niceList')
                .doc(FirebaseAuth.instance.currentUser!.uid),
            <String, dynamic>{},
          );

          // niceを加算
          transaction.set(
            postDocRef,
            {
              'nice': FieldValue.increment(1),
            },
            SetOptions(merge: true),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  // いいねを削除
  static Future<void> unNice(String postId, {String? parentId}) async {
    /*
    /posts/{postId}                          // 例:post001
           ├── postedAt: Timestamp
           ├── userid: String                       // 投稿者ID
           ├── text: String                         // 本文
           ├── response: String                     // AIからの返信
           ├── nice: int
           ├── /niceList
           │   └── {userId}: {}
    */
    // ドキュメント参照用
    DocumentReference postDocRef;

    // 親Idが送られてるなら返信用
    if (parentId != null) {
      postDocRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(parentId)
          .collection('replies')
          .doc(postId);
    } else {
      postDocRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    }

    await FirebaseFirestore.instance.runTransaction(
      (transaction) async {
        // 参照を追加
        final niceDocRef = postDocRef
            .collection('niceList')
            .doc(FirebaseAuth.instance.currentUser!.uid);

        // 存在するなら削除
        final niceSnapshot = await transaction.get(niceDocRef);

        if (niceSnapshot.exists) {
          transaction.delete(niceDocRef);

          // いいね数を減らす
          transaction.set(
            postDocRef,
            {'nice': FieldValue.increment(-1)},
            SetOptions(merge: true),
          );
        }
      },
    );
  }

  // フォロー時の処理
  static Future<void> follow(String followeeId) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;

      // すでにフォローしているか確認
      final docSnap = await db
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("follows")
          .doc(followeeId)
          .get();

      if (docSnap.exists) {
        throw Exception("Already registered.");
      }

      // トランザクション開始
      await db.runTransaction((transaction) async {
        final now = FieldValue.serverTimestamp();

        // 自分のfollowsコレクションに追加
        final followRef = db
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("follows")
            .doc(followeeId);
        transaction.set(followRef, {
          'followedAt': now,
          'notify': true,
        });

        // 相手のfollowersコレクションに追加
        final followerRef = db
            .collection("users")
            .doc(followeeId)
            .collection("followers")
            .doc(FirebaseAuth.instance.currentUser!.uid);
        transaction.set(followerRef, {
          'followedAt': now,
        });

        // フォロー数をインクリメント
        final myProfileRef = db
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("profile")
            .doc("profile");
        transaction.set(myProfileRef, {
          'followCount': FieldValue.increment(1),
        }, SetOptions(merge: true));

        // フォロワー数をインクリメント
        final theirProfileRef = db
            .collection("users")
            .doc(followeeId)
            .collection("profile")
            .doc("profile");
        transaction.set(theirProfileRef, {
          'followerCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
      });
    }
    catch(e)
    {
      print(e);
    }
  }

  // フォロー解除時の処理
  static Future<void> unFollow(String followeeId) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      // すでにフォローしているか確認
      final docSnap = await db
          .collection("users")
          .doc(uid)
          .collection("follows")
          .doc(followeeId)
          .get();

      if (!docSnap.exists) {
        throw Exception("Not yet registered.");
      }

      // トランザクション開始
      await db.runTransaction((transaction) async {
        // 自分のfollowsコレクションから削除
        final followRef = db
            .collection("users")
            .doc(uid)
            .collection("follows")
            .doc(followeeId);
        transaction.delete(followRef);

        // 相手のfollowersコレクションから削除
        final followerRef = db
            .collection("users")
            .doc(followeeId)
            .collection("followers")
            .doc(uid);
        transaction.delete(followerRef);

        // 自分の followCount を1減らす
        final myProfileRef = db
            .collection("users")
            .doc(uid)
            .collection("profile")
            .doc("profile");
        transaction.set(
          myProfileRef,
          {'followCount': FieldValue.increment(-1)},
          SetOptions(merge: true),
        );

        // 相手の followerCount を1減らす
        final theirProfileRef = db
            .collection("users")
            .doc(followeeId)
            .collection("profile")
            .doc("profile");
        transaction.set(
          theirProfileRef,
          {'followerCount': FieldValue.increment(-1)},
          SetOptions(merge: true),
        );
      });
    } catch (e) {
      print(e);
    }
  }

  // 通報内容を保存(投稿id,カテゴリー,通報内容)
  static Future<void> report({
    required String postId,
    required String category,
    required String text,
  }) async{
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      // トランザクション開始
      await db.runTransaction((transaction) async {
        final now = FieldValue.serverTimestamp();

        // レポート内容を追加
        final reportRef = db
            .collection("report")
            .doc();
        transaction.set(reportRef, {
          'reportAt': now,
          'reporterId' : uid,
          'postId' : postId,
          'category' : category,
        });

        // ポストに通報数を加算
        final reportedPostId  = db
            .collection("posts")
            .doc(postId);
        transaction.set(reportedPostId, {
          'reportedCount' : FieldValue.increment(1)
        },SetOptions(merge: true));
      });
    } catch (e) {
      print(e);
    }
  }
}

/*// /// /// /// /// /// /// 以下firebaseDB全体構造// /// /// /// /// /// /// /// /// /// /// /

/users/{userId}                          // 例:user001
├── name: String                         // 田中太郎
├── iconUrl: String (URL)
├── nationality: String                  // Japan
├── /profile
│   ├── introduction: String             // 自己紹介(100文字程度)
│   ├── lastAction: Timestamp
│   ├── followCount: int
│   └── followerCount: int
├── /hidden
│   └── {hiddenUserId}: {}               // 非表示ユーザーリスト
├── /follows
│   ├─── {followsUserId}                // フォローしているユーザーのID
│       └── followedAt: Timestamp
├─── /followers
    ├─── {followerUserId}               // フォロワーのユーザーID
        └── followedAt: Timestamp


/posts/{postId}                          // 例:post001
├── postedAt: Timestamp
├── userid: String                       // 投稿者ID
├── text: String                         // 本文
├── response: String                     // AIからの返信
├── nice: int
├── /niceList
│   └── {userId}: {}                     // いいねしたユーザー
├─── /replies
    ├─── {replyId}                       // reply001
        ├── repliedAt: Timestamp
        ├── userid: String               // リプライ投稿者ID
        ├── text: String
        ├── nice: int
        └── /niceList
            └── {userId}: {}             // リプライにいいねしたユーザー

 */
