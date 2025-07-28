import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cordial/data_models/profile.dart';
import 'package:cordial/data_models/post.dart';
import 'package:cordial/data_models/timeline.dart';
import 'package:cordial/data_models/user_summary.dart';
import 'package:cordial/data_models/user_summary_list.dart';

class DatabaseRead {
  // タイムラインを取得<以前の最後のドキュメントを参照し返す>
  static Future<Timeline?> timeline([String? userId , DocumentSnapshot? lastVisible]) async {
    /*
    /posts/{postId}                          // 例:post001
    ├── postedAt: Timestamp
    ├── userid: String                       // 投稿者ID
    ├── text: String                         // 本文
    ├── selectedAiId: int                    // 返答したAIid
    ├── response: String                     // AIからの返信
    ├── nice: int
    ├── /niceList
    │   └── {userId}: {}                     // いいねしたユーザー
     */
    try {
      // ポスト時間でソート
      var query = FirebaseFirestore.instance
          .collection('posts') // コレクションID
          .orderBy('postedAt', descending: true);

      // ドキュメントが渡されていたらその次のドキュメントから取得する
      if (lastVisible != null) {
        query = query.startAfterDocument(lastVisible);
      }

      // ユーザーIDが渡されてるならそのユーザーで絞り込む
      if (userId != null) {
        query = query.where('userid', isEqualTo: userId);
      }

      // タイムラインを取得
      final result = await query.limit(10).get();

      if (result.docs.isEmpty) {
        return null;
      }

      // 取得したドキュメントをリストList<Post>にするためのデータ取得(並列実行)
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

        // 二つの要素を待つ
        final results = await Future.wait([niceFuture, userFuture]);

        return Post(
          postedAt: _timeAgoFromTimestamp(doc['postedAt'] as Timestamp),
          id: postId,
          userId: userId,
          userName: results[1]['name'] ?? 'unknown',
          iconUrl: results[1]['iconUrl'],
          postText: doc['text'] ?? '',
          selectedAiId: doc['selectedAiId'] ?? 0,
          response: doc['response'] ?? '',
          nice: doc['nice'] ?? 0,
          isNice: results[0].exists
        );
      }).toList();

      // 取得を待つ
      final posts = await Future.wait(futures);

      // タイムラインを最後のDocumentSnapshotと返す。
      return Timeline(posts: posts, lastVisible: result.docs.last);
    } catch (e) {
      print(e);
    }
    return null;
  }

  // 投稿の返信を取得する
  static Future<Timeline?> replyTimeline(String postId,[DocumentSnapshot? lastVisible]) async{
    /*
    /posts/{postId}                // いいねしたユーザー
          ├─── /replies
          ├─── {replyId}                       // reply001
               ├── repliedAt: Timestamp
               ├── userid: String               // リプライ投稿者ID
               ├── text: String
               ├── nice: int
               └── /niceList
                   └── {userId}: {}             // リプライにいいねしたユーザー
     */

    try {
      // ポスト時間でソート
      var query = FirebaseFirestore.instance
          .collection('posts') // コレクションID
          .doc(postId)
          .collection('replies')
          .orderBy('nice', descending: true)
          .orderBy('repliedAt', descending: true);

      // ドキュメントが渡されていたらその次のドキュメントから取得する
      if (lastVisible != null) {
        query = query.startAfterDocument(lastVisible);
      }

      // タイムラインを取得
      final result = await query.limit(10).get();

      if (result.docs.isEmpty) {
        return null;
      }

      // 取得したドキュメントをリストList<Post>にするためのデータ取得(並列実行)
      final futures = result.docs.map((doc) async {
        final replyId = doc.id;
        final userId = doc['userid'];

        final niceFuture = FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('replies')
            .doc(replyId)
            .collection('niceList')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

        final userFuture =
        FirebaseFirestore.instance.collection('users').doc(userId).get();

        // 二つの要素を待つ
        final results = await Future.wait([niceFuture, userFuture]);

        return Post(
          postedAt: _timeAgoFromTimestamp(doc['repliedAt'] as Timestamp),
          id: replyId,
          userId: userId,
          userName: results[1]['name'] ?? 'unknown',
          iconUrl: results[1]['iconUrl'],
          selectedAiId: 0,
          postText: doc['text'] ?? '',
          response: '',
          nice: doc['nice'] ?? 0,
          isNice: results[0].exists,
        );
      }).toList();

      // 取得を待つ
      final posts = await Future.wait(futures);

      // タイムラインを最後のDocumentSnapshotと返す。
      return Timeline(posts: posts, lastVisible: result.docs.last);
    } catch (e) {
      print(e);
    }

    return null;
  }

  // フォローやフォロワーリストを返す。
  static Future<UserSummaryList?> followerList({required String userId}) => followList(userId :userId,follower : true);
  static Future<UserSummaryList?> followList({required String userId,DocumentSnapshot? lastVisible,bool? follower}) async {
    /*
    /users/{userId}                          // 例:user001
    ├── /follows
    │   ├─── {followsUserId}                // フォローしているユーザーのID
    │       └── followedAt: Timestamp
    ├─── /followers
        ├─── {followerUserId}               // フォロワーのユーザーID
            └── followedAt: Timestamp
     */

    try {
      // フォロー時間でソート
      var query = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(follower  == true ? 'followers' : 'follows')
          .orderBy('followedAt', descending: true);

      // ドキュメントが渡されていたらその次のドキュメントから取得する
      if (lastVisible != null) {
        query = query.startAfterDocument(lastVisible);
      }

      // データを個数制限をつけ取得
      final result = await query.limit(10).get();

      if (result.docs.isEmpty) {
        return null;
      }

      // 取得したドキュメントをリスト<List>UserSummaryにするためのデータ取得(並列実行)
      final futures = result.docs.map((doc) async {
        final followedAt = doc['followedAt'];
        final userId = doc.id;

        final userFuture =
        FirebaseFirestore.instance.collection('users').doc(userId).get();

        // 二つの要素を待つ
        final results = await Future.wait([userFuture]);

        return UserSummary(
            userName: results[0]['name'],
            iconUrl: results[0]['iconUrl'],
            userId: userId,
            time: _timeAgoFromTimestamp(followedAt as Timestamp)
        );
      }).toList();

      // 取得を待つ
      final userSummaries = await Future.wait(futures);

      // タイムラインを最後のDocumentSnapshotと返す。
      return UserSummaryList(userSummaries: userSummaries, lastVisible: result.docs.last);
    } catch (e) {
      print(e);
    }

    return null;
  }

  // プロフィールを取得
  static Future<Profile?> profile(String userid) async {
    /*
    /users/{userId}                          // 例:user001
    ├── name: String                         // 田中太郎
    ├── iconUrl: String (URL)
    ├── nationality: String                  // Japan
    ├── /profile
    │   ├── introduction: String             // 自己紹介(100文字程度)
    │   ├── backgroundPath: String             // 背景
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
          name: data?['name'] ?? '・・・・',
          iconUrl: data?['iconUrl'] as String?,
          introduction: dataDeep?['introduction'] ?? 'null',
          backgroundPath: dataDeep?['backgroundPath'] as String?,
          followCount: dataDeep?['followCount'] ?? 0,
          followerCount: dataDeep?['followerCount'] ?? 0);
    } catch (e) {
      print(e);
      return null;
    }
  }

  // アイコンのURLをDBから返す
  static Future<String?> iconUrl([String? userid]) async {
    try {
      var result = await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(userid ?? FirebaseAuth.instance.currentUser?.uid)
          .get(); // ドキュメントID

      var data = result.data();

      return data?['iconUrl'];
    } catch (e) {
      return null;
    }
  }

  // ユーザー名が存在しているかを確認する
  static Future<bool> isUserName() async {
    try {
      var result = await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(); // ドキュメントID

      var data = result.data();

      // nullならfalse
      bool isUser = data?['name'] != null ? true : false;

      return isUser;
    } catch (e) {
      return false;
    }
  }

  // ユーザー名を取得する
  static Future<String?> myUserName() async {
    try {
      var result = await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(); // ドキュメントID

      var data = result.data();

      return data?['name'];
    } catch (e) {
      return null;
    }
  }

  // 相手をフォローしているかを確認する
  static Future<bool> isFollowing(String followeeId) async{
    try {
      var result = await FirebaseFirestore.instance.collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection("follows")
          .doc(followeeId)
          .get();
      // 存在するならtrueを返す
      if(result.exists){
        return true;
      }
    }catch(e){
      return false;
    }
    return false;
  }

  // タイムスタンプで相対時間を返す
  static String _timeAgoFromTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final time = timestamp.toDate();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'たった今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      // 7日以上前は日付表示（例: 2025/5/19）
      return '${time.year}/${time.month}/${time.day}';
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
│   ├── backgroundPath: String             // 背景
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
├── selectedAiId: int                    // 返答したAIid
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
