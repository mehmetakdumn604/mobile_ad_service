import 'package:flutter/material.dart';
import 'package:flutter_good_ads/src/helpers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoodBannerAdaptiveAnchored extends StatefulWidget {
  const GoodBannerAdaptiveAnchored({
    Key? key,
    required this.adUnitId,
    this.adRequest = const AdRequest(),
    this.enableLog = true,
  }) : super(key: key);

  final String adUnitId;
  final AdRequest adRequest;
  final bool enableLog;

  @override
  State<GoodBannerAdaptiveAnchored> createState() =>
      _GoodBannerAdaptiveAnchoredState();
}

class _GoodBannerAdaptiveAnchoredState
    extends State<GoodBannerAdaptiveAnchored> {
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      debug('Unable to get height of anchored banner.',enableLog: widget.enableLog);
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: widget.adRequest,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debug('$ad loaded: ${ad.responseInfo}',enableLog: widget.enableLog);
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debug('Anchored adaptive banner failedToLoad: $error',enableLog: widget.enableLog);
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_anchoredAdaptiveAd != null && _isLoaded) {
      return SizedBox(
        width: _anchoredAdaptiveAd!.size.width.toDouble(),
        height: _anchoredAdaptiveAd!.size.height.toDouble(),
        child: AdWidget(ad: _anchoredAdaptiveAd!),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
