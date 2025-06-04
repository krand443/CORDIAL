import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cordial/function/signin.dart';
import 'package:http/http.dart' as http;

class Firestore {

  // ギャラリーから画像を選択して、リサイズ後、Firebaseにアップロード
  static Future<int> upload(File originalFile, String fileName,
      [int _width = 300, int _height = 300]) async {
    try {
      // クロップしてからリサイズ
      final img.Image square =
          await _cropToSquare(originalFile, _width, _height) as img.Image;
      final resized = img.copyResize(square, width: _width, height: _height);

      // PNG形式でバイトデータにエンコード
      final Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resized));

      // 一時ディレクトリに画像を保存
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/resized.png');
      await file.writeAsBytes(resizedBytes);

      // Firebase Storage にアップロード
      final ref = FirebaseStorage.instance
          .ref()
          .child('${FirebaseAuth.instance.currentUser?.uid}/$fileName.png');
      await ref.putFile(file);

      print('アップロード完了！');
      return 0;
    } catch (e) {
      print(e);
      return 1;
    }
  }

  // 自分のアイコン画像を取得する関数
  static Future<String?> myIcon() async {
    try{
      // firebase上に画像があればそれを返す
      final ref = FirebaseStorage.instance
          .ref()
          .child('${FirebaseAuth.instance.currentUser?.uid}/icon.png');
      final url = await ref.getDownloadURL(); // ← 画像の公開URLを取得
      return url;
    }
    catch(e)
    {
      print(e);
      return null;
    }
  }

  // 元画像の中央を基準にクロップする関数(デフォルトは正方形に切り取る)
  static Future<img.Image?> _cropToSquare(File originalFile,
      [int _width = 1, int _height = 1]) async {
    // バイトデータに変換
    final Uint8List imageBytes = await originalFile.readAsBytes();
    // Dartのimageパッケージで画像をデコード
    final image = img.decodeImage(imageBytes);
    if (image != null) {
      final double imageRatio = image.width / image.height;
      final double targetRatio = _width / _height;

      // 新規画像サイズ
      int xSize, ySize;

      // 切り取り始める座標
      int xOffset;
      int yOffset;

      // 比率があっていない方の幅を再定義する。
      if (imageRatio > targetRatio) {
        xSize = (image.height * targetRatio).toInt();
        ySize = image.height;

        xOffset = (image.width - xSize) ~/ 2;
        yOffset = 0;
      } else {
        xSize = image.width;
        ySize = (image.width / targetRatio).toInt();

        xOffset = 0;
        yOffset = (image.height - ySize) ~/ 2;
      }

      return img.copyCrop(
        image,
        x: xOffset,
        y: yOffset,
        width: xSize,
        height: ySize,
      );
    } else {
      return null;
    }
  }
}
