import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyLicenseDialog {
  // ライセンス追加(アプリ起動時などで一度だけ呼ぶ)
  static void addCustomLicense() {
    LicenseRegistry.addLicense(() async* {
      yield const LicenseEntryWithLineBreaks(
          ['assets/animations/like.riv'],
          '''
Heart/like click\n
Author: khitrina.daria\n
License: CC BY 4.0\n
Date: 23 December 2024\n
Source: https://rive.app/marketplace/15550-29335-heartlike-click/\n
'''
      );
    });
  }

  static Future<void> show(BuildContext context) async {
    await showDialog(
      barrierColor: Colors.grey.withOpacity(0.1), // ダイアログの周囲の色
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 角を丸くする
        ),
        child: LicensePage(
          applicationName: 'CORDIAL',
          applicationVersion: '1.0.0',
          applicationLegalese: '© 2025 Ruten LLC',
          applicationIcon: Image.asset(
            'assets/icon.png',
            width: 48,
            height: 48,
          ),
        ),
      ),
    );
  }
}
