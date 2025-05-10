import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin.dart';


class Database {

  //ユーザーを追加
  static Future<void> addUser(String name) async
  {
    try {
      // ドキュメント作成
      await FirebaseFirestore.instance
          .collection('users') // コレクションID
          .doc(SignIn.currentUser?.uid) // ドキュメントID
          .set({'name': name}); // データ
    }
    catch(e) {
      print(e);
    }
  }

}