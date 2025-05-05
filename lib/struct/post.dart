//Postを管理するクラス
class Post
{
  //投稿自体のid
  final int id;

  //ユーザーid(16桁のランダムな数)
  final int userId;

  //いいねの数
  final int nice;

  //投稿内容
  final String postText;

  //AIの返信
  final String returnText;

  //コンストラクタ
  const Post({
    required this.id,
    required this.userId,
    required this.postText,
    required this.returnText,
    this.nice = 0,
  });
}