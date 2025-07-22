// Profileのデータ構造
class Profile
{
  // ユーザー名
  final String name;

  // アイコンのURL
  final String? iconUrl;

  // 自己紹介文
  final String introduction;

  // 背景画像のローカルパス
  final String? backgroundPath;

  // フォロー数
  final int followCount;

  // フォロワー数
  final int followerCount;

  Profile({
    required this.name,
    required this.iconUrl,
    required this.introduction,
    required this.backgroundPath,
    required this.followCount,
    required this.followerCount
  });
}