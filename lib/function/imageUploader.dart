import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:cordial/function/signin.dart';

class ImageUploader {
  // ギャラリーから画像を選択して、200x200にリサイズ後、Firebaseにアップロード
  static Future<int> upload(File originalFile,String fileName) async {
    try {
      //バイトデータに変換
      final Uint8List imageBytes = await originalFile.readAsBytes();

      //Dartのimageパッケージで画像をデコード
      final image = img.decodeImage(imageBytes);
      if (image == null) return 1; // デコード失敗時は中断

      //正方形にクロップしてから200x200にリサイズ
      final square = _cropToSquare(image);
      final resized = img.copyResize(square, width: 200, height: 200);

      //PNG形式でバイトデータにエンコード
      final Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resized));

      //一時ディレクトリに画像を保存
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/resized.png');
      await file.writeAsBytes(resizedBytes);

      //Firebase Storage にアップロード
      final ref = FirebaseStorage.instance.ref().child(
          '${SignIn.currentUser!.uid}/$fileName.png');
      await ref.putFile(file);

      print('アップロード完了！');
      return 0;
    }
    catch(e)
    {
      print (e);
      return 1;
    }
  }

  // 元画像の中央を基準に正方形にクロップする処理
  static img.Image _cropToSquare(img.Image image) {
    final size = image.width < image.height ? image.width : image.height;
    final xOffset = (image.width - size) ~/ 2;
    final yOffset = (image.height - size) ~/ 2;
    return img.copyCrop(
      image,
      x: xOffset,
      y: yOffset,
      width: size,
      height: size,
    );
  }

}
