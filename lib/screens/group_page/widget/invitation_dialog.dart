import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<void> invitationDialog(BuildContext context,String groupId) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        // ダイアログの角を丸くする
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        // タイトル
        title: const Text(
          '招待コード',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
        // コンテンツ（テキストフィールドとキャンセルボタン）
        content: FutureBuilder<String>(
          future: _getInvitationCode(groupId),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
              // 非同期処理中
              return SizedBox(
                height: 80,           // 好きな大きさに調整
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              // エラー発生時の表示
              return Text('エラー: ${snapshot.error}');
            } else{
              // データ取得成功
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 招待コードを表示
                      Text(
                        snapshot.data!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'コピー',
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: snapshot.data ?? ''));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('コピーしました')),
                          );
                        },
                      ),
                    ],
                  ),
                  const Text(
                    '有効期限24時間',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // ダイアログを閉じる
                    },
                    child: const Text(
                      '閉じる',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      );
    },
  );
}

// 招待コードを取得
Future<String> _getInvitationCode(String groupId) async{
  final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
  final uri = Uri.parse(
    'https://asia-northeast1-projectcordial-596bd.cloudfunctions.net/makeInvitation',
  );

  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer:$idToken', // ユーザーのトークンで認証
    },
    body: jsonEncode({
      'groupId' : groupId,
    }),
  );

  return response.statusCode == 200 ? response.body : 'ERROR';

}
