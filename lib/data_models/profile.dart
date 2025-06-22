import 'post.dart';

// Profileのデータ構造
class Profile
{
  // ユーザー名
  final String name;

  // アイコンのURL
  final String iconUrl;

  // 自己紹介文
  final String introduction;

  // フォロー数
  final int followCount;

  // フォロワー数
  final int followerCount;

  Profile({
    required this.name,
    required this.iconUrl,
    required this.introduction,
    required this.followCount,
    required this.followerCount
  });
}
/*
/users/{userId}                          // 例:user001
├── username: String                     // 田中太郎
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
│       ├── followedAt: Timestamp
│       └── notify: boolean             // 通知の切り替え
├─── /followers
├─── {followerUserId}               // フォロワーのユーザーID
└── followedAt: Timestamp

 */