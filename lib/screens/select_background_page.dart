import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 背景画像選択画面
class SelectBackgroundPage extends StatefulWidget {
  const SelectBackgroundPage({super.key});

  @override
  SelectBackgroundPageState createState() => SelectBackgroundPageState();
}

class SelectBackgroundPageState extends State<SelectBackgroundPage> {
  String? _selectedImage;

  late List<String> imagePaths;

  @override
  void initState() {
    super.initState();
    imagePaths = _getBackgroundImages().map((path) {
      return 'assets/background/$path';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('背景を選択'),),
        body: GridView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: imagePaths.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 20,
            childAspectRatio: 9 / 7,
          ),
          itemBuilder: (context, index) {
            final path = imagePaths[index];
            return GestureDetector(
              onTap: () {
                if (_selectedImage == path) {
                  Navigator.pop(context, _selectedImage);
                }

                setState(() {
                  _selectedImage = path;
                });
                // 選択後の処理があればここに追加（例: Navigator.popで返す）
              },
              child: Stack(
                children: [
                  Image.asset(path, fit: BoxFit.cover),
                  if (_selectedImage == path)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.add, color: Colors.white, size: 50),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 背景画像一覧を設定しておく(flutterでは自動取得は不可)
  List<String> _getBackgroundImages() {
    return [
      '00001.jpg',
      '00002.jpg',
      '00003.jpg',
      '00004.jpg',
      '00005.jpg',
      '00006.jpg',
      '00007.jpg',
      '00008.jpg',
      '00009.jpg',
      '00010.jpg',
      '00011.jpg',
      '00012.jpg',
      '00013.jpg',
      '00014.jpg',
      '00015.jpg',
      '00016.jpg',
      '00017.jpg',
      '00018.jpg',
      '00019.jpg',
      '00020.jpg',
      '00021.jpg',
      '00022.jpg',
      '00023.jpg',
      '00024.jpg',
      '00025.jpg',
      '00026.jpg',
      '00027.jpg',
      '00028.jpg',
      '00029.jpg',
      '00030.jpg',
      '00031.jpg',
      '00032.jpg',
      '00033.jpg',
      '00034.jpg',
      '00035.jpg',
      '00036.jpg',
      '00037.jpg',
      '00038.jpg',
      '00039.jpg',
      '00040.jpg',
      '00041.jpg',
      '00042.jpg',
      '00043.jpg',
      '00044.jpg',
      '00045.jpg',
      '00046.jpg',
      '00047.jpg',
    ];
  }
}
