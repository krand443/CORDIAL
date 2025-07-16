// 投稿一つ分のデータ構造
class Post
{
  // ポスト時間
  final String postedAt;

  // 投稿自体のid
  final String id;

  // ユーザーid
  final String userId;

  // ユーザー名
  final String userName;

  // アイコンのURL
  final String iconUrl;

  // 投稿内容
  final String postText;

  // 指定AI
  final int selectedAiId;

  // AIの返信
  final String response;

  // いいねの数
  int nice;

  // 既に自分がniceを押しているかどうかの変数
  bool isNice;

  Post({
    required this.postedAt,
    required this.id,
    required this.userName,
    required this.iconUrl,
    required this.userId,
    required this.postText,
    required this.selectedAiId,
    required this.response,
    required this.nice,
    required this.isNice,
  });
}