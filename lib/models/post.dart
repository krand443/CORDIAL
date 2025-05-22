//Postを管理するためのクラス
class Post
{
  //ポスト時間
  final String postedAt;

  //投稿自体のid
  final String id;

  //ユーザーid
  final String userId;

  //ユーザー名
  final String userName;

  //アイコンのURL
  final String iconUrl;

  //投稿内容
  final String postText;

  //AIの返信
  final String response;

  //いいねの数
  final int nice;

  //既に自分がniceを押しているかどうかの変数
  final bool isNice;

  const Post({
    required this.postedAt,
    required this.id,
    required this.userName,
    required this.iconUrl,
    required this.userId,
    required this.postText,
    required this.response,
    required this.nice,
    required this.isNice,
  });
}

//ポスト構造
/*
/posts/{postId}                          //例:post001
├── postedAt: Timestamp
├── userid: String                       //投稿者ID
├── text: String                         //本文
├── response: String                     //AIからの返信
├── nice: int
├── /niceList
│   └── {userId}: {}                     //いいねしたユーザー
├─── /replies
    ├─── {replyId}                       //reply001
        ├── RepliedAt: Timestamp
        ├── userid: String               //リプライ投稿者ID
        ├── text: String
        ├── nice: int
        └── /niceList
            └── {userId}: {}
 */