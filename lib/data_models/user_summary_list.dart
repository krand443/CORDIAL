import 'package:cordial/data_models/user_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// フォローやフォロワー一覧を出すためのデータ構造
class UserSummaryList
{
  // 取得したユーザーのリスト
  final List<UserSummary> userSummaries;

  // 取得したユーザーの最後の要素を保存(次回検索時に渡すため)
  DocumentSnapshot lastVisible;

  UserSummaryList({
    required this.userSummaries,
    required this.lastVisible
  });
}