import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static const _adsDisabledKey = 'ads_disabled';
  static const _androidAppId = String.fromEnvironment('ADMOB_ANDROID_APP_ID');
  static const _androidBannerId = String.fromEnvironment('ADMOB_ANDROID_BANNER_ID');
  static const _androidInterstitialId = String.fromEnvironment('ADMOB_ANDROID_INTERSTITIAL_ID');

  static const _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  static String get bannerUnitId => _androidBannerId.isNotEmpty ? _androidBannerId : _testBannerId;
  static String get interstitialUnitId => _androidInterstitialId.isNotEmpty ? _androidInterstitialId : _testInterstitialId;
  static bool get hasProductionAppId => _androidAppId.isNotEmpty;

  static Future<void> initialize() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
  }

  static Future<bool> adsDisabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adsDisabledKey) ?? false;
  }

  static Future<void> setAdsDisabled(bool disabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adsDisabledKey, disabled);
  }

  static Future<InterstitialAd?> loadInterstitial() async {
    if (await adsDisabled()) return null;
    InterstitialAd? loaded;
    await InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => loaded = ad,
        onAdFailedToLoad: (_) {},
      ),
    );
    return loaded;
  }
}
