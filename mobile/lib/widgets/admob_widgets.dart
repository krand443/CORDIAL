import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMob {
  static final List<BannerAd> _adPool = []; // 広告プール
  static final List<bool> _adPoolStatus = []; // 各広告の使用状況
  static const int _poolSize = 10; // プールサイズ
  static bool _isPoolInitialized = false;

  // 広告プールを初期化（アプリ起動時に呼び出す）
  static Future<void> initializeAdPool() async {
    if (_isPoolInitialized) return;

    String bannerUnitId = kDebugMode
        ? "ca-app-pub-3940256099942544/6300978111"
        : "ca-app-pub-3931303225943785/1369237582";

    for (int i = 0; i < _poolSize; i++) {
      final bannerAd = BannerAd(
        adUnitId: bannerUnitId,
        size: AdSize.largeBanner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('広告プール[$i] ロード完了');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('広告プール[$i] ロード失敗: $error');
            ad.dispose();
          },
        ),
      );

      _adPool.add(bannerAd);
      _adPoolStatus.add(false); // 未使用状態で初期化

      // 広告をロード
      await bannerAd.load();
    }

    _isPoolInitialized = true;
    print('広告プール初期化完了: $_poolSize個');
  }

  // プールから利用可能な広告を取得
  static BannerAd? _getAvailableAd() {
    for (int i = 0; i < _adPool.length; i++) {
      if (!_adPoolStatus[i]) {
        _adPoolStatus[i] = true; // 使用中にマーク
        return _adPool[i];
      }
    }
    return null; // 利用可能な広告なし
  }

  // 広告を返却（使用終了時）
  static void _returnAd(BannerAd ad) {
    final index = _adPool.indexOf(ad);
    if (index != -1) {
      _adPoolStatus[index] = false; // 未使用状態に戻す
    }
  }

  // 広告ウィジェットを返す
  static Widget getBannerAdUnit() {
    return FutureBuilder<void>(
      future: initializeAdPool(), // プールが初期化されるまで待機
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('広告の初期化に失敗しました'),
          );
        }

        // プールから広告を取得
        final bannerAd = _getAvailableAd();
        if (bannerAd == null) {
          return const Center(
            child: Text('利用可能な広告がありません'),
          );
        }

        return _BannerAdDisplay(
          bannerAd: bannerAd,
          onDispose: () => _returnAd(bannerAd), // 使用終了時に返却
        );
      },
    );
  }

  // プール全体を破棄
  static void disposePool() {
    for (final ad in _adPool) {
      ad.dispose();
    }
    _adPool.clear();
    _adPoolStatus.clear();
    _isPoolInitialized = false;
  }
}

// 個別の広告表示ウィジェット
class _BannerAdDisplay extends StatefulWidget {
  final BannerAd bannerAd;
  final VoidCallback onDispose;

  const _BannerAdDisplay({
    required this.bannerAd,
    required this.onDispose,
  });

  @override
  State<_BannerAdDisplay> createState() => _BannerAdDisplayState();
}

class _BannerAdDisplayState extends State<_BannerAdDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.bannerAd.size.width.toDouble(),
      height: widget.bannerAd.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: widget.bannerAd),
    );
  }

  @override
  void dispose() {
    widget.onDispose(); // 広告をプールに返却
    super.dispose();
  }
}