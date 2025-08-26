import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

// インターネット接続状況関連の関数を置いておくクラス
class NetworkStatus {
  static Future<bool> check([BuildContext? context]) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }

    // contextが渡されてるならスナックバーを表示する。
    if(context != null) {
      if (!context.mounted) return false;
      // SnackBarを表示
      const snackBar = SnackBar(
        content: Text('インターネットに接続されていません。'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return false;
  }
}
