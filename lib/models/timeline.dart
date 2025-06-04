import 'post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// タイムラインを保持する構造
class Timeline
{
  // 取得したポストのリスト
  final List<Post> posts;

  // 取得したポストの最後の要素を保存(次回検索時に渡すため)
  DocumentSnapshot lastVisible;

  Timeline({
    required this.posts,
    required this.lastVisible
  });
}