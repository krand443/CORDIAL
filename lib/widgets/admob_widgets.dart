import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// 広告ウィジェットを返す
class AdMob {

  static Widget getBannerAdUnit() {
    // Android のとき
    String bannerUnitId = kDebugMode
        ? "ca-app-pub-3940256099942544/6300978111" //テスト用
        : "ca-app-pub-3931303225943785/1369237582"; //本番用

    BannerAd myBanner = BannerAd(
        adUnitId: bannerUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener());
    myBanner.load();

    return Container(
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: myBanner),
    );
  }
}
