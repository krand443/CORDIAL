import 'package:cloud_firestore/cloud_firestore.dart';

// 表示形式を変換する関数をまとめておくクラス
class ChangeFormat{

  // タイムスタンプで相対時間を返す
  static String timeAgoFromTimestamp(Timestamp timestamp) {
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