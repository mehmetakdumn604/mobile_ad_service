import 'dart:async';

import 'package:flutter_good_ads/src/extensions.dart';
import 'package:flutter_good_ads/src/helpers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoodRewarded {
  static Map<String, int> lastImpressions = {};
  static final Map<String, RewardedAd> _instance = {};
  static final Map<String, int> _interval = {};

  /// [interval] minimum interval between 2 impressions (millis), default: 60000
  const GoodRewarded({
    required this.adUnitId,
    this.adRequest = const AdRequest(),
    this.interval = 60000,
    this.enableLog= true,
  });

  final String adUnitId;
  final AdRequest adRequest;
  final int interval;
  final bool enableLog;

  /// return [RewardedAd], or throw [LoadAdError] if error
  Future<RewardedAd> load() async {
    _interval[adUnitId] = interval;
    final Completer<RewardedAd> result = Completer();
    await RewardedAd.load(
        adUnitId: adUnitId,
        request: adRequest,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (RewardedAd ad) =>
                  debug('interstitial_showedFullScreenContent($adUnitId): ${ad.print()}',enableLog: enableLog),
              onAdDismissedFullScreenContent: (RewardedAd ad) {
                debug('interstitial_dismissedFullScreenContent($adUnitId): ${ad.print()}',enableLog: enableLog);
                ad.dispose();
                _instance.remove(adUnitId);
              },
              onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
                debug(
                    'interstitial_failedToShowFullScreenContent($adUnitId): ${ad.print()},Error: $error',enableLog: enableLog);
                ad.dispose();
                _instance.remove(adUnitId);
              },
              onAdImpression: (RewardedAd ad) =>
                  debug('interstitial_impression($adUnitId): ${ad.print()}',enableLog: enableLog),
            );
            _instance[adUnitId] = ad;
            debug('interstitial_loaded($adUnitId): ${ad.print()}',enableLog: enableLog);
            result.complete(ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debug('interstitial_failedToLoaded($adUnitId): ${error.toString()}',enableLog: enableLog);
            result.completeError(error);
          },
        ));
    return result.future;
  }

  /// show the InterstitialAd by [adUnitId], must call [load] first.
  ///
  /// if [reloadAfterShow] is true, it will automatically call reload for
  /// you after show. default: true
  Future<void> show({
    bool reloadAfterShow = true,
    void Function(AdWithoutView, RewardItem)? onUserEarnedReward,
    Function? onError,
  }) async {
    // Ad instance of adUnitId has loaded fail or already showed.
    if (_instance[adUnitId] == null) {
      if (onError != null) {
        onError();
      }
      if (reloadAfterShow) {
        load();
      }

      return;
    }
    if (DateTime.now().millisecondsSinceEpoch - lastImpressions.get(adUnitId) > _interval.get(adUnitId)) {
      await _instance[adUnitId]!.show(
        onUserEarnedReward: onUserEarnedReward ?? (_, __) {},
      );
      lastImpressions.set(adUnitId, DateTime.now().millisecondsSinceEpoch);
      if (reloadAfterShow) {
        load();
      }
    }
    else {
      if (onError != null) {
        onError();
      }
    }
  }
}
