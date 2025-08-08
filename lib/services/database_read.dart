import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cordial/data_models/profile.dart';
import 'package:cordial/data_models/post.dart';
import 'package:cordial/data_models/timeline.dart';
import 'package:cordial/data_models/user_summary.dart';
import 'package:cordial/data_models/user_summary_list.dart';
import 'package:cordial/data_models/group.dart';
import 'package:cordial/utils/change_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cordial/enums/ranking_type.dart';


class DatabaseRead {
  // タイムラインを取得<以前の最後のドキュメントを参照し返す>
  static Future<Timeline?> timeline(
      [String? userId, DocumentSnapshot? lastVisible]) async {

    // ルートに配置した投稿を参照
    CollectionReference query = FirebaseFirestore.instance
        .collection('posts');

    return await _commonTimeline(query,userId: userId,lastVisible: lastVisible);
  }

  // ランキング表示用
  static Future<Timeline?> rankingTimeline(RankingType rankingType,
      [ DocumentSnapshot? lastVisible,int? limit]) async {

    // ルートに配置した投稿を参照
    CollectionReference query = FirebaseFirestore.instance
        .collection('posts');

    return await _commonTimeline(query,rankingType: rankingType,lastVisible: lastVisible,limit: limit);
  }

  // グループの投稿を取得
  static Future<Timeline?> groupTimeline(String groupId,
      [DocumentSnapshot? lastVisible]) async {

    // グループに配置した投稿を参照
    CollectionReference query = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('posts');

    return await _commonTimeline(query,lastVisible: lastVisible);
  }

  // 上二つで使用する共通部分
  static Future<Timeline?>  _commonTimeline(
      CollectionReference query, {
        String? userId,
        RankingType? rankingType,
        DocumentSnapshot? lastVisible,
        int? limit,
      }) async{
    try {
      Query<Object?> newQuery;

      switch (rankingType) {
        case RankingType.weekly://週間ランキング
          final DateTime now = DateTime.now();
          final DateTime oneWeekAgo = now.subtract(const Duration(days: 7));
          newQuery = query.where('postedAt', isGreaterThanOrEqualTo: oneWeekAgo)
              .orderBy('nice', descending: true); // いいね数順
          break;
        case RankingType.total://総合ランキング
          newQuery = query.orderBy('nice', descending: true); // いいね数順
          break;
        default:// デフォルトはポスト時間でソート
          newQuery = query.orderBy('postedAt', descending: true);
      }

      // ドキュメントが渡されていたらその次のドキュメントから取得する
      if (lastVisible != null) {
        newQuery = newQuery.startAfterDocument(lastVisible);
      }

      // ユーザーIDが渡されてるならそのユーザーで絞り込む
      if (userId != null) {
        newQuery = newQuery.where('userid', isEqualTo: userId);
      }

      // タイムラインを取得
      final result = await newQuery.limit(limit ?? 10).get();

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
            postedAt:
            ChangeFormat.timeAgoFromTimestamp(doc['postedAt'] as Timestamp),
            id: postId,
            userId: userId,
            userName: results[1]['name'] ?? 'unknown',
            iconUrl: results[1]['iconUrl'],
            postText: doc['text'] ?? '',
            selectedAiId: doc['selectedAiId'] ?? 0,
            response: doc['response'] ?? '',
            nice: doc['nice'] ?? 0,
            isNice: results[0].exists);
      }).toList();

      // 取得を待つ
      final posts = await Future.wait(futures);

      // タイムラインを最後のDocumentSnapshotと返す。
      return Timeline(posts: posts, lastVisible: result.docs.last);
    } catch (e) {
      print('\x1B[31m$e\x1B[0m');
      return null;
    }
  }

  // 投稿の返信を取得する
  static Future<Timeline?> replyTimeline(String postId,
      [DocumentSnapshot? lastVisible]) async {

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
          postedAt:
              ChangeFormat.timeAgoFromTimestamp(doc['repliedAt'] as Timestamp),
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
      print('\x1B[31m$e\x1B[0m');
      return null;
    }
  }

  // フォローやフォロワーリストを返す。
  static Future<UserSummaryList?> followerList({required String userId,DocumentSnapshot? lastVisible,}) =>
      followList(userId: userId,lastVisible:lastVisible, follower: true,);

  static Future<UserSummaryList?> followList(
      {required String userId,
      DocumentSnapshot? lastVisible,
      bool? follower}) async {

    try {
      // フォロー時間でソート
      var query = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(follower == true ? 'followers' : 'follows')
          .orderBy('followedAt', descending: true);

      // ドキュメントが渡されていたらその次のドキュメントから取得する
      if (lastVisible != null) {
        query = query.startAfterDocument(lastVisible);
      }

      // データを個数制限をつけ取得
      final result = await query.limit(20).get();

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
            time: ChangeFormat.timeAgoFromTimestamp(followedAt as Timestamp));
      }).toList();

      // 取得を待つ
      final userSummaries = await Future.wait(futures);

      // タイムラインを最後のDocumentSnapshotと返す。
      return UserSummaryList(
          userSummaries: userSummaries, lastVisible: result.docs.last);
    } catch (e) {
      print('\x1B[31m$e\x1B[0m');
      print('\x1B[31m$e\x1B[0m');
    }

    return null;
  }

  // グループのメンバーを返す
  static Future<UserSummaryList?> groupMemberList(
      {required String groupId,
        DocumentSnapshot? lastVisible,}) async {

    try {
      // 参加時間でソート
      var query = FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .orderBy('joinedAt', descending: false);

      // ドキュメントが渡されていたらその次のドキュメントから取得する
      if (lastVisible != null) {
        query = query.startAfterDocument(lastVisible);
      }

      // データを個数制限をつけ取得
      final result = await query.limit(20).get();

      if (result.docs.isEmpty) {
        return null;
      }

      // 取得したドキュメントをリスト<List>UserSummaryにするためのデータ取得(並列実行)
      final futures = result.docs.map((doc) async {
        final joinedAt = doc['joinedAt'];
        final userId = doc.id;

        final userFuture =
        FirebaseFirestore.instance.collection('users').doc(userId).get();

        // 二つの要素を待つ
        final results = await Future.wait([userFuture]);

        return UserSummary(
            userName: results[0]['name'],
            iconUrl: results[0]['iconUrl'],
            userId: userId,
            time: ChangeFormat.timeAgoFromTimestamp(joinedAt as Timestamp));
      }).toList();

      // 取得を待つ
      final userSummaries = await Future.wait(futures);

      // タイムラインを最後のDocumentSnapshotと返す。
      return UserSummaryList(
          userSummaries: userSummaries, lastVisible: result.docs.last);
    } catch (e) {
      print('\x1B[31m$e\x1B[0m');
      print('\x1B[31m$e\x1B[0m');
    }

    return null;
  }

  // プロフィールを取得
  static Future<Profile?> profile(String userid) async {
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
      print('\x1B[31m$e\x1B[0m');
      return null;
    }
  }

  // 所属グループを返す
  static Future<List<Group>?> joinedGroups() async {
    try {

      var result = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('groups')
          .limit(30)
          .get();

      List<Group> groups = [];

      // 並列で group ドキュメントを取得
      List<Future<DocumentSnapshot>> futures = result.docs.map((data) {
        return FirebaseFirestore.instance
            .collection('groups')
            .doc(data.id)
            .get();
      }).toList();

      List<DocumentSnapshot> groupInfos = await Future.wait(futures);

      for (int i = 0; i < groupInfos.length; i++) {
        var groupInfo = groupInfos[i];
        var data = result.docs[i];

        if (groupInfo['name'] == null || groupInfo['numPeople'] == null) continue;

        groups.add(
          Group(
            id: data.id,
            name: groupInfo['name'],
            leaderId: groupInfo['leaderId'] ?? '',
            icon: IconData(
              (groupInfo['icon'] as int?) ?? Icons.star.codePoint,
              fontFamily: 'MaterialIcons',
            ),
            backgroundColor: Color(
              (groupInfo['backgroundColor'] as int?) ?? Colors.red.shade600.value,
            ),
            numPeople: groupInfo['numPeople'],
            lastAction: (groupInfo['lastAction'] as Timestamp?),
          ),
        );
      }

      groups.sort((a, b) {
        if (a.lastAction == null && b.lastAction == null) return 0;
        if (a.lastAction == null) return 1; // nullは後ろに
        if (b.lastAction == null) return -1;
        return b.lastAction!.compareTo(a.lastAction!); // 新しい順（降順）
      });
      
      return groups;
    } catch (e) {
      print('\x1B[31m$e\x1B[0m');
      return null;
    }
  }

  // アイコンのURLをDBから返す
  static Future<String?> iconUrl([String? userid]) async {
    try {
      var result = await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(userid ?? FirebaseAuth.instance.currentUser!.uid)
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
      print('\x1B[31m$e\x1B[0m');
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
      print('\x1B[31m$e\x1B[0m');
      return null;
    }
  }

  // 相手をフォローしているかを確認する
  static Future<bool> isFollowing(String followeeId) async {
    try {
      var result = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection("follows")
          .doc(followeeId)
          .get();
      // 存在するならtrueを返す
      if (result.exists) {
        return true;
      }
    } catch (e) {
      print('\x1B[31m$e\x1B[0m');
      return false;
    }
    return false;
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
