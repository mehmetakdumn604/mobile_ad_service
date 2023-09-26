import 'package:flutter/material.dart';
import 'package:flutter_good_ads/src/extensions.dart';
import 'package:flutter_good_ads/src/helpers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoodBannerStandard extends StatefulWidget {
  static Map<String, int> lastImpressions = {};

  /// [interval] minimum interval between 2 impressions (millis), default: 60000
  const GoodBannerStandard({
    Key? key,
    required this.adUnitId,
    this.adRequest = const AdRequest(),
    this.adSize = AdSize.banner,
    this.interval = 60000,
    this.enableLog = true,
  }) : super(key: key);

  final String adUnitId;
  final AdRequest adRequest;
  final AdSize adSize;
  final int interval;
  final bool enableLog;

  @override
  State<GoodBannerStandard> createState() => _GoodBannerStandardState();
}

class _GoodBannerStandardState extends State<GoodBannerStandard> {
  late final BannerAdListener listener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) {
      debug('banner_loaded(${widget.adUnitId}): ${ad.responseInfo.toString()}',enableLog: widget.enableLog);
      GoodBannerStandard.lastImpressions
          .set(widget.adUnitId, DateTime.now().millisecondsSinceEpoch);
    },
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      debug(
          'banner_load_failed(${widget.adUnitId}): ${ad.responseInfo.toString()}, Error: ${error.toString()}',enableLog: widget.enableLog);
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) =>
        debug('banner_opened(${widget.adUnitId}): ${ad.responseInfo.toString()}',enableLog: widget.enableLog),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) =>
        debug('banner_closed(${widget.adUnitId}): ${ad.responseInfo.toString()}',enableLog: widget.enableLog),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) =>
        debug('banner_impression(${widget.adUnitId}): ${ad.responseInfo.toString()}',enableLog: widget.enableLog),
  );

  late final BannerAd myBanner = BannerAd(
    adUnitId: widget.adUnitId,
    size: widget.adSize,
    request: widget.adRequest,
    listener: listener,
  );

  bool hasLoadAd = false;

  @override
  void initState() {
    super.initState();
    if (DateTime.now().millisecondsSinceEpoch -
            GoodBannerStandard.lastImpressions.get(widget.adUnitId) >
        widget.interval) {
      loadAd();
    } else {
      // if initState but can not load immediately, delay and then load
      Future.delayed(Duration(milliseconds: widget.interval), () {
        if (hasLoadAd == false) {
          loadAd();
        }
      });
    }
  }

  Future<void> loadAd() async {
    await myBanner.load();
    GoodBannerStandard.lastImpressions
        .set(widget.adUnitId, DateTime.now().millisecondsSinceEpoch);
    setState(() {
      hasLoadAd = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasLoadAd) {
      return Container(
        alignment: Alignment.center,
        width: myBanner.size.width.toDouble(),
        height: myBanner.size.height.toDouble(),
        child: AdWidget(ad: myBanner),
      );
    } else {
      return const SizedBox();
    }
  }
}
