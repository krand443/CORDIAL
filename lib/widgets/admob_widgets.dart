import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// 広告ウィジェットを返す
class AdMob {
  static BannerAd? _bannerAd; // 広告を保持
  static bool _isAdLoaded = false; // 広告がロード済みかどうかのフラグ

  // 広告のロード処理
  static Future<void> _loadBannerAd() async {
    // 広告がまだロードされていない、またはロード済みでない場合のみロードを実行
    if (_bannerAd == null || !_isAdLoaded) {
      // 広告ユニットIDを設定（デバッグ用と本番用）
      String bannerUnitId = kDebugMode
          ? "ca-app-pub-3940256099942544/6300978111" // テスト用
          : "ca-app-pub-3931303225943785/1369237582"; // 本番用

      _bannerAd = BannerAd(
        adUnitId: bannerUnitId,
        size: AdSize.largeBanner, // 広告サイズをラージバナーに設定
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            // 広告ロード成功時
            _isAdLoaded = true; // ロード成功フラグをtrueに
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            // 広告ロード失敗時
            ad.dispose(); // ロード失敗した広告を破棄
            _bannerAd = null;
            _isAdLoaded = false; // ロード失敗フラグをfalseに
          },
        ),
      );
      await _bannerAd!.load(); // 広告のロードを実行し、完了を待つ
    }
  }

  // 広告ウィジェットを返す
  static Widget getBannerAdUnit() {
    return FutureBuilder<void>(
      future: _loadBannerAd(), // 広告のロード処理をFutureとして監視
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // ロード中の場合、ローディングインジケーターを表示
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        } else if (snapshot.hasError) {
          // エラーが発生した場合、エラーメッセージを表示
          return const Center(
            child: Text('広告の読み込みに失敗しました'),
          );
        } else if (_bannerAd != null && _isAdLoaded) {
          // 広告が正常にロードされた場合、AdWidgetを表示
          return Container(
            // 広告の幅と高さを設定
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            alignment: Alignment.center,
            child: AdWidget(ad: _bannerAd!),
          );
        } else {
          // それ以外の場合（例: ロード失敗後に広告が表示されない状態）、空のSizedBoxを返す
          return const SizedBox();
        }
      },
    );
  }

  // 明示的に広告を破棄したいときの関数
  static void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;
  }
}

