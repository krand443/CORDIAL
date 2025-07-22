// 簡単にユーザー情報を表示するためのデータ構造
class UserSummary
{
  // ユーザーid
  final String userId;

  // ユーザー名
  final String userName;

  // アイコンのURL
  final String? iconUrl;

  // 時間
  final String time;

  UserSummary({
    required this.userName,
    required this.iconUrl,
    required this.userId,
    required this.time,
  });
}

