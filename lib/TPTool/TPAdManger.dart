import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:cloudx_flutter/cloudx.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:treeperks/TPTool/TPLocalProvider.dart';
import 'package:treeperks/TPTool/TPInitSdk.dart';
import 'package:thinkup_sdk/at_interstitial.dart';
import 'package:thinkup_sdk/at_interstitial_response.dart';
import 'package:thinkup_sdk/at_listener.dart';
import 'package:thinkup_sdk/at_rewarded.dart';
import 'package:thinkup_sdk/at_rewarded_response.dart';
import '../TPDialog/TPAccountDialogs.dart';
import '../TPDialog/TPDialogs.dart';
import '../TPModel/TPAdModel.dart';
import 'TPFKManger.dart';
import 'TPLogger.dart';
import 'TPNumberHelpers.dart';
import 'TPTBAEventTool.dart';

Map<String, dynamic> tp_defaultAdConfig = {
  "iv": [
    {
      "unitId": "n1hqnb4dvjkq8b",
      "platform": "topon",
      "adtype": "interstitial",
      "ctime": 3000,
      "weight": 3
    },
    {
      "unitId": "nyr8CPqDRNZRcZmZeBVIK",
      "platform": "cloudx",
      "adtype": "interstitial",
      "ctime": 3000,
      "weight": 3
    }
  ],
  "rv": [
    {
      "unitId": "n1hqnb4dvsjg3n",
      "platform": "topon",
      "adtype": "reward",
      "ctime": 3000,
      "weight": 3
    },
    {
      "unitId": "FGPueNGqaa88h1fp-_-Y4",
      "platform": "cloudx",
      "adtype": "reward",
      "ctime": 3000,
      "weight": 3
    }
  ]
};

class TPPigAdModel {
  String type;
  String source;

  double ecpm;
  String ad_identifer;
  int status;
  String networkName;
  String sdk;

  TPPigAdModel({
    required this.type,
    required this.source,
    required this.ecpm,
    required this.ad_identifer,
    required this.status,
    required this.networkName,
    required this.sdk,
  });

  String getTypeToServer() {
    if (type == "reward") {
      return "rv";
    } else {
      return "int";
    }
  }
}

class TPPigAds {
  static final TPPigAds _instance = TPPigAds._internal();

  factory TPPigAds() {
    return _instance;
  }

  TPPigAds._internal();

  TPAdModel? _TPPigAdModel;

  TPAdModel? psPigAdModel = TPAdModel.fromJson(tp_defaultAdConfig);

  bool _pigAdDelegateCreated = false;

  bool init_suc = false;

  String? quizAdPlaceID;

  Function(bool)? onAdClosed;
  // 保存上次播放广告时间
  DateTime? _savedTime = DateTime.now();
  // 保存上次播放到关闭广告时间
  DateTime? _savedPlayAndCloseTime;

  DateTime int_start = DateTime.now();

  DateTime read_start = DateTime.now();

  int _adShowed = 0;
  int _adClicked = 0;
  int adShowedToday = 0;
  double _adRevenues = 0.0;

  List<TPPigAdModel> _ads = [];
  // 是否显示广告中
  late bool is_showAd = false;
  // 测试打开，上线关闭
  final bool skipAd = false;

  Future<void> init({TPAdModel? inputAd}) async {
    _ads = [];
    ASLogger.instance.debug("$runtimeType init ad json,remote value is $inputAd");
    try {
      await setAdConfigData(inputAdModel: inputAd ?? psPigAdModel);
      _getCacheData();

      if (!_prepareRequest()) {
        return;
      }
      _requestAd();
    } catch (error) {
      ASLogger.instance.debug("$runtimeType init ad error $error");
    }
  }

  void addAds(List<TPAdUnitModel> list) {
    for (final d in list) {
      if (d.platform != "topon" && d.platform != "cloudx") {
        continue;
      }
      _ads.add(
        TPPigAdModel(
          type: d.adType,
          source: d.platform,
          ecpm: 0,
          ad_identifer: d.unitId,
          status: 0,
          networkName: "",
          sdk: "",
        ),
      );
    }
  }

  void _getCacheData() {
    _adShowed = TPLocalProvider.instance.tp_ad_show_number;
    _adClicked = 0;
    adShowedToday = 0;
    _adRevenues = 0;
  }

  void tp_showAd(
      BuildContext context,
      String placeID, {
        required Function(bool) onCacheResponse,
        required Function(bool) adDidClosed,
        bool mustShow = false,
        bool showDialog = true,
      }) async {
    if (skipAd) {
      adDidClosed.call(true);
      resetHandler();
      return;
    }
    // 展示上限
    if (TPLocalProvider.instance.tp_ad_show_index >
        TPFKManger().fkModel.behavior.ad_daily_show &&
        TPFKManger().fkModel.ui.behavior == 1) {
      unawaited(TPDialogs.showAccount(context, TPAccountDialogKind.adLimit));
      onCacheResponse.call(false);
      resetHandler();
      return;
    }
    // 风控
    if (await TPFKManger().tp_checkAllStatus()) {
      ASLogger.instance.debug('风控不发起广告显示');
      if (context.mounted) {
        unawaited(
          TPDialogs.showToast(
            context,
            'Something went wrong, please try again later.',
          ),
        );
      }
      tp_event_fire('tp_fk_un', {});
      onCacheResponse.call(false);
      resetHandler();
      return;
    }

    if (someAdIsShowing()) {
      ASLogger.instance.debug("$runtimeType ad is showing,cancel this request");
      return;
    }
    onAdClosed ??= adDidClosed;
    quizAdPlaceID ??= placeID;
    String adType = placeID.contains("rv") ? "rv" : "int";
    bool defaultMode = _TPPigAdModel?.alternateMode ?? false;
    ASLogger.instance.debug("$runtimeType ad service request to show [$quizAdPlaceID], ad type is $adType, use mode #$defaultMode");
    tp_event_fire('nskdh_ad_chance', {"ad_pos_id": placeID});

    if (defaultMode == false) {
      _showA(
        adType,
        placeID,
        onCacheResponse,
        context: context.mounted ? context : null,
        showDialog: showDialog,
      );
    } else {
      _showB(
        adType,
        placeID,
        onCacheResponse,
        context: context.mounted ? context : null,
        showDialog: showDialog,
      );
    }
  }

  void _showA(
      String adType,
      String placeID,
      Function(bool) onCacheResponse, {
        BuildContext? context,
        bool showDialog = true,
      }) async {
    final isInt = adType == "int";
    final realType = isInt ? "interstitial" : "reward";

    final showIndex = _findShowIndex(realType, false);

    if (showIndex != -1) {
      final ad = _ads[showIndex];

      ASLogger.instance.debug("$runtimeType prepare to show ad [A],type=$adType, id=${ad.ad_identifer}");

      final showed = await _tryShowAd(ad, context, placeID);
      if (showed) return;

      // show 失败兜底
      onCacheResponse(false);
      resetHandler();
      ad.status = 0;
      _requestAd(defaultIndex: [showIndex]);
      return;
    } else {
      if (context != null && showDialog == true) {
        unawaited(showfaildDiolog(context));
      }
    }

    ASLogger.instance.debug("$runtimeType prepare to show ad [A],type=$adType but no caches find!!");
    tp_event_fire("nskdh_ad_impression_fail", {
      "ad_pos_id": placeID,
      "reason": 'notPrepared',
    });

    onCacheResponse(false);
    resetHandler();

    final notRequestingAd = _findNotRequestingAds(realType);
    if (notRequestingAd.isNotEmpty) {
      _requestAd(defaultIndex: notRequestingAd);
      return;
    }

    ASLogger.instance.debug("$runtimeType onCacheResponse is not ready!!! error $quizAdPlaceID");
  }

  int _findShowIndex(String adType, bool compare) {
    int showIndex = -1;
    double bestEcpm = double.negativeInfinity;

    for (int i = 0; i < _ads.length; i++) {
      final ad = _ads[i];

      // 必须是已缓存广告
      if (ad.status != 1) continue;

      // 非 compare 模式：只选指定类型
      if (!compare && ad.type != adType) continue;

      // compare 模式下：reward 场景允许跨类型比较
      if (compare && adType != "reward" && ad.type != adType) continue;

      if (ad.ecpm > bestEcpm) {
        bestEcpm = ad.ecpm;
        showIndex = i;
      }
    }

    return showIndex;
  }

  List<int> _findNotRequestingAds(String adType) {
    final result = <int>[];
    for (int i = 0; i < _ads.length; i++) {
      if (_ads[i].status == 0 && _ads[i].type == adType) {
        result.add(i);
      }
    }
    return result;
  }

  Future<bool> _tryShowAd(
      TPPigAdModel ad,
      BuildContext? context,
      String placeID,
      ) async {
    if (ad.source == "cloudx") {
      if (ad.type == "reward") {
        final ready = await CloudX.isRewardedReady(adUnitId: ad.ad_identifer);
        if (!ready) {
          tp_event_fire("nskdh_ad_impression_fail", {
            "ad_pos_id": placeID,
            "reason": 'notPrepared',
          });
          return false;
        }
        is_showAd = true;
        CloudX.showRewarded(adUnitId: ad.ad_identifer);
      } else {
        final ready = await CloudX.isInterstitialReady(
          adUnitId: ad.ad_identifer,
        );
        if (!ready) {
          tp_event_fire("nskdh_ad_impression_fail", {
            "ad_pos_id": placeID,
            "reason": 'notPrepared',
          });
          return false;
        }
        is_showAd = true;
        CloudX.showInterstitial(adUnitId: ad.ad_identifer);
      }
    } else if (ad.type == "reward") {
      final ready = await ATRewardedManager.rewardedVideoReady(
        placementID: ad.ad_identifer,
      );
      if (!ready) {
        tp_event_fire("nskdh_ad_impression_fail", {
          "ad_pos_id": placeID,
          "reason": 'notPrepared',
        });
        return false;
      }
      is_showAd = true;
      ATRewardedManager.showRewardedVideo(placementID: ad.ad_identifer);
    } else {
      final ready = await ATInterstitialManager.hasInterstitialAdReady(
        placementID: ad.ad_identifer,
      );
      if (!ready) {
        tp_event_fire("nskdh_ad_impression_fail", {
          "ad_pos_id": placeID,
          "reason": 'notPrepared',
        });
        return false;
      }
      is_showAd = true;
      ATInterstitialManager.showInterstitialAd(placementID: ad.ad_identifer);
    }

    ad.status = 2;

    return true;
  }

  void _showB(
      String adType,
      String placeID,
      Function(bool) onCacheResponse, {
        BuildContext? context,
        bool showDialog = false,
      }) async {
    final isInt = adType == "int";
    final realType = isInt ? "interstitial" : "reward";

    final showIndex = _findShowIndex(realType, true);

    if (showIndex != -1) {
      final ad = _ads[showIndex];

      ASLogger.instance.debug("$runtimeType prepare to show ad [B],type=$adType, id=${ad.ad_identifer}");

      final showed = await _tryShowAd(ad, context, placeID);
      if (showed) return;

      // show 失败兜底
      onCacheResponse(false);
      resetHandler();
      ad.status = 0;
      _requestAd(defaultIndex: [showIndex]);
      return;
    } else {
      if (context != null && showDialog == true) {
        unawaited(showfaildDiolog(context));
      }
    }

    ASLogger.instance.debug("$runtimeType prepare to show ad [B],type=$adType but no caches find!!");
    tp_event_fire("nskdh_ad_impression_fail", {
      "ad_pos_id": placeID,
      "reason": 'notPrepared',
    });

    onCacheResponse(false);
    resetHandler();

    final notRequestingAd = _findNotRequestingAds(realType);
    if (notRequestingAd.isNotEmpty) {
      _requestAd(defaultIndex: notRequestingAd);
      return;
    }

    ASLogger.instance.debug("$runtimeType onCacheResponse is not ready!!! error $quizAdPlaceID");
  }

  void adImpression(Map extMap) async {
    ASLogger.instance.debug('extMap1=$extMap');
    double ecpms = extMap['publisher_revenue'] ?? 0.0;
    String adunit_format = extMap['adunit_format'] ?? '';
    tp_ad_fire({
      "strange": ecpms * 1000000,
      "shiv": (extMap["network_name"] as String?)?.toLowerCase(),
      "pothole": 'topon_sdk',
      "pharmacy": extMap['adunit_id'],
      "lenin": quizAdPlaceID,
      "buckskin": adunit_format.contains('Rewarded') ? 'rv' : 'int',
    });
    adRevenues(ecpms);
    // to sdk
    AdjustAdRevenue adjustAdRevenue = AdjustAdRevenue('topon_sdk');
    adjustAdRevenue.adRevenueNetwork = extMap["network_name"];
    adjustAdRevenue.setRevenue(ecpms, "USD");
    adjustAdRevenue.adRevenuePlacement = quizAdPlaceID;
    adjustAdRevenue.adRevenueUnit = extMap['adunit_id'];
    Adjust.trackAdRevenue(adjustAdRevenue);
    TPFacebookAnalytics.logPurchase(ecpms, "USD");
  }

  void adImpressionClondx(CloudXAd cloudxAd) async {
    double ecpms = cloudxAd.revenue;
    String adunit_format = cloudxAd.adFormat.value;
    ASLogger.instance.debug('adunit_format=$adunit_format');
    tp_ad_fire({
      "strange": ecpms * 1000000,
      "shiv": cloudxAd.networkName.toLowerCase(),
      "pothole": 'cloudx_sdk',
      "pharmacy": cloudxAd.adUnitId,
      "lenin": quizAdPlaceID,
      "buckskin": adunit_format.contains('rewarded') ? 'rv' : 'int',
    });
    adRevenues(ecpms);
    // to sdk
    AdjustAdRevenue adjustAdRevenue = AdjustAdRevenue('publisher_sdk');
    adjustAdRevenue.adRevenueNetwork = cloudxAd.networkName;
    adjustAdRevenue.setRevenue(ecpms, "USD");
    adjustAdRevenue.adRevenuePlacement = quizAdPlaceID;
    adjustAdRevenue.adRevenueUnit = cloudxAd.adUnitId;
    Adjust.trackAdRevenue(adjustAdRevenue);
    TPFacebookAnalytics.logPurchase(ecpms, "USD");
  }

  // 显示失败弹框
  Future<void> showfaildDiolog(BuildContext context) async {
    final isConnected = await TPNetworkUtils.isConnected();
    if (!context.mounted) return;

    ASLogger.instance.debug(isConnected ? '有网加载失败' : '设备无网络连接');
    unawaited(
      TPDialogs.showAccount(
        context,
        isConnected
            ? TPAccountDialogKind.adUnavailable
            : TPAccountDialogKind.network,
      ),
    );
  }

  void adShowed() async {
    _adShowed += 1;

    ASLogger.instance.debug("$runtimeType ad show times $_adShowed");
    await TPLocalProvider.instance.updateint(
      TPLocalProvider.instance.tp_ad_show_numberName,
      TPLocalProvider.instance.tp_ad_show_number + 1,
    );
    await TPLocalProvider.instance.updateint(
      TPLocalProvider.instance.tp_ad_all_numberName,
      TPLocalProvider.instance.tp_ad_all_number + 1,
    );
    if (TPLocalProvider.instance.tp_ad_show_number % 5 == 0 &&
        TPLocalProvider.instance.tp_ad_show_number > 0) {
      tp_event_fire("cash_ad_detail", {
        "ad_from": TPLocalProvider.instance.tp_ad_show_number ?? "",
      });
    }

    update();
  }

  void adClicked() async {
    _adClicked += 1;

    update();
  }

  int getAdShowCount() {
    return _adShowed;
  }

  void adRevenues(double revenue) {
    _adRevenues += revenue;
    update();
  }

  update() async {}
}

extension TPAdServiceExtension on TPPigAds {
  Future<void> setAdConfigData({TPAdModel? inputAdModel}) async {
    _TPPigAdModel = inputAdModel;
  }

  void _requestAd({List<int>? defaultIndex}) async {
    for (int i = 0; i < _ads.length; i++) {
      if (defaultIndex != null && !defaultIndex.contains(i)) {
        continue;
      }
      TPPigAdModel ad = _ads[i];
      int status = ad.status;
      String type = ad.type;
      String source = ad.source;
      String adID = ad.ad_identifer;

      if (status == 0) {
        if (type == "interstitial") {
          if (source == "cloudx") {
            CloudX.loadInterstitial(adUnitId: adID);
          } else {
            ATInterstitialManager.loadInterstitialAd(
              placementID: adID,
              extraMap: {},
            );
          }
        } else if (type == "reward") {
          if (source == "cloudx") {
            CloudX.loadRewarded(adUnitId: adID);
          } else {
            ATRewardedManager.loadRewardedVideo(
              placementID: adID,
              extraMap: {},
            );
          }
        }
        ASLogger.instance.debug("$runtimeType ad requesting [start],status = $status, type is $type, source is $source, id is $adID");
      } else if (status == 1) {
        ASLogger.instance.debug("$runtimeType ad requesting [requesting] status = $status, type is $type, source is $source, id is $adID");
      } else {
        ASLogger.instance.debug("$runtimeType ad requesting [requested] status = $status, type is $type, source is $source, id is $adID");
      }
      tp_event_fire("ad_request", {
        "ad_code_id": adID,
        "ad_format": type,
        "ad_source_client": source,
      });
    }
  }

  bool _prepareRequest() {
    if (_TPPigAdModel == null) {
      ASLogger.instance.debug("$runtimeType request ad start,but ad model empty...");
      return false;
    }

    addAds(_TPPigAdModel!.iv);
    addAds(_TPPigAdModel!.rv);
    if (_ads.isEmpty) {
      ASLogger.instance.debug("$runtimeType request ad start,but datasource model empty...");
      return false;
    }

    if (!_pigAdDelegateCreated) {
      _createListener();
    }
    return true;
  }

  void _createListener() {
    _toponIntListener();
    _toponRvListener();
    _cloudxIntListener();
    _cloudxRvListener();
    _pigAdDelegateCreated = true;
  }

  void _toponIntListener() {
    ATListenerManager.interstitialEventHandler.listen((value) {
      switch (value.interstatus) {
        case InterstitialStatus.interstitialAdFailToLoadAD:
          _adDidLoadFailed(value.placementID, value.requestMessage, 'topon');
          break;
      // interstitial load finish
        case InterstitialStatus.interstitialAdDidFinishLoading:
          _adDidFinishLoad(toponInt: value);
          break;
      // interstitial play start, some AD platforms have this callback.
        case InterstitialStatus.interstitialAdDidStartPlaying:
          break;
      // interstitial play end, some AD platforms have this callback.
        case InterstitialStatus.interstitialAdDidEndPlaying:
          break;
      // interstitial play fail, some AD platforms have this callback.
        case InterstitialStatus.interstitialDidFailToPlayVideo:
          _adDidDisplayedError(value.placementID, value.requestMessage);
          break;
      // interstitial show succeed
        case InterstitialStatus.interstitialDidShowSucceed:
          adImpression(value.extraMap);
          _adDidDisplayed(
            adID: value.placementID,
            ad_network: value.extraMap['network_name'],
          );
          break;
      // interstitial show fail
        case InterstitialStatus.interstitialFailedToShow:
          break;
      // interstitial clicked
        case InterstitialStatus.interstitialAdDidClick:
          adClicked();
          break;
      // Deeplink
        case InterstitialStatus.interstitialAdDidDeepLink:
          break;
      // interstitial closed
        case InterstitialStatus.interstitialAdDidClose:
          _adDidHidden(adId: value.placementID);
          break;
        case InterstitialStatus.interstitialUnknown:
          break;
        case InterstitialStatus.interstitialAdDidMultipleLoaded:
        case InterstitialStatus.interstitialAdDidAdSourceBiddingAttempt:
          break;
        case InterstitialStatus.interstitialAdDidAdSourceBiddingFilled:
          break;
        case InterstitialStatus.interstitialAdDidAdSourceBiddingFail:
          break;
        case InterstitialStatus.interstitialAdDidAdSourceAttempt:
          break;
        case InterstitialStatus.interstitialAdDidAdSourceLoadFilled:
          break;
        case InterstitialStatus.interstitialAdDidAdSourceLoadFail:
          break;
        case InterstitialStatus.interstitialAdDidReward:
          // TODO: Handle this case.
          break;
      }
    });
  }

  void _toponRvListener() async {
    ATListenerManager.rewardedVideoEventHandler.listen((value) {
      switch (value.rewardStatus) {
      // ad load fail
        case RewardedStatus.rewardedVideoDidFailToLoad:
          _adDidLoadFailed(value.placementID, value.requestMessage, 'topon');
          break;
      // ad load finish
        case RewardedStatus.rewardedVideoDidFinishLoading:
          _adDidFinishLoad(toponReward: value);
          break;
      // ad video start play
        case RewardedStatus.rewardedVideoDidStartPlaying:
          adImpression(value.extraMap);
          _adDidDisplayed(
            adID: value.placementID,
            ad_network: value.extraMap['network_name'],
          );
          break;
      // ad video start end
        case RewardedStatus.rewardedVideoDidEndPlaying:
          break;
      // ad video fail to play
        case RewardedStatus.rewardedVideoDidFailToPlay:
          _adDidDisplayedError(value.placementID, value.requestMessage);
          break;
      // The rewarded is successful, it is recommended to issue the reward in this callback
        case RewardedStatus.rewardedVideoDidRewardSuccess:
          break;
      // ad video clicked
        case RewardedStatus.rewardedVideoDidClick:
          adClicked();
          break;
      //Deeplink
        case RewardedStatus.rewardedVideoDidDeepLink:
          break;
        case RewardedStatus.rewardedVideoDidClose:
          _adDidHidden(adId: value.placementID);
          break;
        case RewardedStatus.rewardedVideoDidAgainStartPlaying:
          break;
      // ad video again play end(only TT)
        case RewardedStatus.rewardedVideoDidAgainEndPlaying:
          break;
      // ad video again fail to play(only TT)
        case RewardedStatus.rewardedVideoDidAgainFailToPlay:
          break;
      // ad video again rewarded success(only TT)
        case RewardedStatus.rewardedVideoDidAgainRewardSuccess:
          break;
      // ad video again clicked(only TT)
        case RewardedStatus.rewardedVideoDidAgainClick:
        case RewardedStatus.rewardedVideoUnknown:
          break;
        case RewardedStatus.rewardedVideoDidMultipleLoaded:
          break;
        case RewardedStatus.rewardedVideoDidAdSourceBiddingAttempt:
          break;
        case RewardedStatus.rewardedVideoDidAdSourceBiddingFilled:
          break;
        case RewardedStatus.rewardedVideoDidAdSourceBiddingFail:
          break;
        case RewardedStatus.rewardedVideoDidAdSourceAttempt:
          break;
        case RewardedStatus.rewardedVideoDidAdSourceLoadFilled:
          break;
        case RewardedStatus.rewardedVideoDidAdSourceLoadFail:
          break;
      }
    });
  }

  void _cloudxIntListener() {
    CloudX.setInterstitialListener(
      CloudXInterstitialListener(
        onAdLoaded: (ad) {
          _adDidFinishLoad(cloudxAd: ad);
        },
        onAdLoadFailed: (adUnitId, error) {
          _adDidLoadFailed(adUnitId, error.message, 'cloudx');
        },
        onAdDisplayed: (ad) {
          adImpressionClondx(ad);
          _adDidDisplayed(adID: ad.adUnitId, ad_network: ad.networkName);
        },
        onAdDisplayFailed: (ad, error) {
          _adDidDisplayedError(ad.adUnitId, error.message);
        },
        onAdHidden: (ad) {
          _adDidHidden(adId: ad.adUnitId);
        },
        onAdClicked: (ad) {},
        onAdRevenuePaid: (ad) {},
      ),
    );
  }

  void _cloudxRvListener() {
    CloudX.setRewardedListener(
      CloudXRewardedListener(
        onAdLoaded: (ad) {
          _adDidFinishLoad(cloudxAd: ad);
        },
        onAdLoadFailed: (adUnitId, error) {
          _adDidLoadFailed(adUnitId, error.message, 'cloudx');
        },
        onAdDisplayed: (ad) {
          adImpressionClondx(ad);
          _adDidDisplayed(adID: ad.adUnitId, ad_network: ad.networkName);
        },
        onAdDisplayFailed: (ad, error) {
          _adDidDisplayedError(ad.adUnitId, error.message);
        },
        onAdHidden: (ad) {
          _adDidHidden(adId: ad.adUnitId);
        },
        onAdClicked: (ad) {},
        onAdRevenuePaid: (ad) {},
        onAdReceivedReward: (ad, reward) {},
      ),
    );
  }

  void _adDidFinishLoad({
    ATInterstitialResponse? toponInt,
    ATRewardResponse? toponReward,
    CloudXAd? cloudxAd,
  }) async {
    String adID = "";
    double revenue = 0;
    String networkName = "";
    String sdk = "";
    if (cloudxAd != null) {
      adID = cloudxAd.adUnitId;
      revenue = cloudxAd.revenue;
      networkName = "cloudx";
      sdk = "cloudx_sdk";
    }
    if (toponInt != null) {
      sdk = "topon_sdk";
      adID = toponInt.placementID;
      revenue = toponInt.extraMap["publisher_revenue"] ?? 0;
      networkName = "topon";
      String intInfo = await ATInterstitialManager.getInterstitialValidAds(
        placementID: adID,
      );
      try {
        List<dynamic> infoMap = json.decode(intInfo);
        if (infoMap.isNotEmpty) {
          Map<String, dynamic> d = infoMap.first;
          revenue = d["publisher_revenue"] ?? 0;
        }
      } catch (error) {
        ASLogger.instance.debug("$runtimeType decode topon int info error $error");
      }
    }
    if (toponReward != null) {
      sdk = "topon_sdk";
      adID = toponReward.placementID;
      networkName = "topon";
      String intInfo = await ATRewardedManager.getRewardedVideoValidAds(
        placementID: adID,
      );
      try {
        List<dynamic> infoMap = json.decode(intInfo);
        if (infoMap.isNotEmpty) {
          Map<String, dynamic> d = infoMap.first;
          revenue = d["publisher_revenue"] ?? 0;
        }
      } catch (error) {
        ASLogger.instance.debug("$runtimeType decode topon int info error $error");
      }
    }

    if (adID.isEmpty) {
      ASLogger.instance.debug("$runtimeType ad did loaded but id is empty id = $adID");
      return;
    }

    int index = _ads.indexWhere((test) => test.ad_identifer == adID);
    if (index == -1) {
      ASLogger.instance.debug("$runtimeType ad did loaded but cant find in ads data from id = $adID");
      return;
    }

    _ads[index].status = 1;
    _ads[index].ecpm = revenue;
    _ads[index].networkName = networkName;
    _ads[index].sdk = sdk;
    ASLogger.instance.debug("$runtimeType ad did load success [${_ads[index].source}] type = ${_ads[index].type} id = ${_ads[index].ad_identifer} ecpm = ${_ads[index].ecpm} network = ${_ads[index].networkName}");
    tp_event_fire("nskdh_ad_return", {
      "ad_code_id": _ads[index].ad_identifer,
      "ad_format": _ads[index].type == "reward" ? "rv" : "int",
      "ad_source_client": _ads[index].networkName,
      "nskdh_ad_request_time": Random().nextInt(4),
    });
  }

  void _adDidLoadFailed(String adID, String reason, String type) {
    int index = _ads.indexWhere((test) => test.ad_identifer == adID);
    if (index == -1) {
      ASLogger.instance.debug("$runtimeType ad did load failed but cant find in ads data from id = $adID");
      return;
    }
    tp_event_fire("nskdh_ad_return_fail", {
      "ad_code_id": quizAdPlaceID ?? "",
      "ad_format": _ads[index].getTypeToServer(),
      "ad_source_client": type,
      "reason": reason,
    });
    // 延迟1s请求下一条避免出现请求频繁报错
    Future.delayed(Duration(seconds: 2), () {
      _requestAd(defaultIndex: [index]);
    });
  }

  Future<void> _adDidDisplayed({
    required String adID,
    required String ad_network,
  }) async {
    // if (TPLocalProvider.instance.tp_bg_music){
    //   TPAudioUtils().pauseBGM();
    // }
    int index = _ads.indexWhere((test) => test.ad_identifer == adID);
    if (index == -1) {
      ASLogger.instance.debug("$runtimeType ad did display but cant find in ads data from id = $adID");
      tp_event_fire('nskdh_ad_show_suc_not_impression', {});
      return;
    }
    _ads[index].status = 2;

    _savedPlayAndCloseTime = DateTime.now();
    await TPLocalProvider.instance.updateint(
      TPLocalProvider.instance.tp_ad_show_indexName,
      TPLocalProvider.instance.tp_ad_show_index + 1,
    );
    await TPLocalProvider.instance.updateint(
      TPLocalProvider.instance.tp_ad_all_numberName,
      TPLocalProvider.instance.tp_ad_all_number + 1,
    );
    // 广告显示
    await TPLocalProvider.instance.updateint(
      TPLocalProvider.instance.tp_ad_show_numberName,
      TPLocalProvider.instance.tp_ad_show_number + 1,
    );

    if (_ads[index].getTypeToServer() == "rv") {
      await TPLocalProvider.instance.updateint(
        TPLocalProvider.instance.tp_ad_reawrd_all_numberName,
        TPLocalProvider.instance.tp_ad_reawrd_all_number + 1,
      );
      // 判断两次播放间隔小于30s
      int secondsDiff = DateTime.now().difference(_savedTime!).inSeconds;
      if (secondsDiff < TPFKManger().fkModel.behavior.ad_short_show.duration &&
          _savedTime != null) {
        // 添加次数
        await TPLocalProvider.instance.updateint(
          TPLocalProvider.instance.tp_ad_short_show_numberName,
          TPLocalProvider.instance.tp_ad_short_show_number + 1,
        );
        // 大于等于次数被风控
        ASLogger.instance.debug('TPFKManger().fkModel.behavior.ad_short_show.value=${TPFKManger().fkModel.behavior.ad_short_show.value}');
        ASLogger.instance.debug('WUUserHelpers().wu_ad_short_show_number=${TPLocalProvider.instance.tp_ad_short_show_number}');
        if (TPFKManger().fkModel.behavior.ad_short_show.value <=
            TPLocalProvider.instance.tp_ad_short_show_number) {
          tp_event_fire('risk_chance', {'risk_from': 'ad_short_show'});
          await TPLocalProvider.instance.updateBool(
            TPLocalProvider.instance.tp_fk_ad_short_showName,
            true,
          );
        }
      }
    }

    ASLogger.instance.debug("$runtimeType ad did display success [${_ads[index].source}] type = ${_ads[index].type} id = ${_ads[index].ad_identifer}");

    adShowed();
  }

  Future<void> _adDidHidden({required String adId}) async {
    // if (TPLocalProvider.instance.tp_bg_music){
    //   TPAudioUtils().playBGM();
    // }
    is_showAd = false;
    // 保存上次关闭广告时间仅限激励
    _savedTime = DateTime.now();
    int index = _ads.indexWhere((test) => test.ad_identifer == adId);
    if (index == -1) {
      ASLogger.instance.debug("$runtimeType ad did hidden but cant find in ads data from id = $adId");
      return;
    }
    ASLogger.instance.debug("$runtimeType ad did hidden success id = $adId");
    _ads[index].status = 0;
    tp_event_fire("nskdh_ad_imp_close", {
      "ad_pos_id": quizAdPlaceID ?? "none",
      "msg": "impsus",
      "ad_format": _ads[index].getTypeToServer(),
      "ad_code_id": _ads[index].ad_identifer,
    });

    if (_ads[index].getTypeToServer() == "rv") {
      // 判断播发到关闭播放间隔小于20s
      int secondsDiff = DateTime.now()
          .difference(_savedPlayAndCloseTime!)
          .inSeconds;
      if (secondsDiff < TPFKManger().fkModel.behavior.ad_short_close.duration &&
          _savedPlayAndCloseTime != null) {
        // 添加次数
        await TPLocalProvider.instance.updateint(
          TPLocalProvider.instance.tp_ad_short_close_numberName,
          TPLocalProvider.instance.tp_ad_short_close_number + 1,
        );
        // 大于等于次数被风控
        if (TPFKManger().fkModel.behavior.ad_short_close.value <=
            TPLocalProvider.instance.tp_ad_short_close_number) {
          tp_event_fire('risk_chance', {'risk_from': 'ad_short_close'});
          await TPLocalProvider.instance.updateBool(
            TPLocalProvider.instance.tp_fk_ad_short_closeName,
            true,
          );
        }
      }
    }

    onAdClosed?.call(true);
    resetHandler();

    _requestAd(defaultIndex: [index]);
  }

  Future<void> _adDidDisplayedError(String adID, String errorString) async {
    int index = _ads.indexWhere((test) => test.ad_identifer == adID);

    if (index == -1) {
      ASLogger.instance.debug("$runtimeType ad did display error but cant find in ads data from id = $adID");
      return;
    }
    _ads[index].status = 0;
    ASLogger.instance.debug("$runtimeType ad did display error [${_ads[index].source}] type = ${_ads[index].type} id = ${_ads[index].ad_identifer}");

    tp_event_fire("nskdh_ad_impression_fail", {
      "ad_pos_id": quizAdPlaceID ?? "",
      "reason": errorString,
    });

    onAdClosed?.call(false);
    resetHandler();

    _requestAd(defaultIndex: [index]);
  }

  bool findTag(List<TPAdUnitModel> data, String adID) {
    bool finded = false;
    for (int i = 0; i < data.length; i++) {
      if (data[i].unitId == adID) {
        finded = true;
        break;
      }
    }
    return finded;
  }

  void resetHandler() {
    if (onAdClosed != null) {
      onAdClosed = null;
    }
    if (quizAdPlaceID != null) {
      quizAdPlaceID = null;
    }
  }

  bool someAdIsShowing() {
    return _ads.any((e) => e.status == 2);
  }
}

class TPNetworkUtils {
  /// 检查当前是否有网络连接（移动数据或Wi-Fi）
  static Future<bool> isConnected() async {
    // 获取当前网络状态
    final connectivityResult = await (Connectivity().checkConnectivity());

    // 判断是否有网络连接
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // 有移动数据或Wi-Fi连接
    }

    return false; // 无网络连接
  }

  /// 监听网络状态变化
  static Stream<ConnectivityResult> getNetworkChanges() {
    return Connectivity().onConnectivityChanged;
  }
}

