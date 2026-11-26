import 'TPLogger.dart';
import 'dart:async';
import 'dart:convert';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_attribution.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:cloudx_flutter/cloudx.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';
import 'package:treeperks/TPTool/TPFKManger.dart';
import 'package:treeperks/TPTool/TPNumberHelpers.dart';
import 'package:treeperks/TPTool/TPLocalProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: 配套源码尚未接入。
// import '../TPModel/TPAdModel.dart';
import '../TPModel/TPFkModel.dart';
import '../TPModel/TPNumberModel.dart';
import 'TPTBAEventTool.dart';
import 'TPToponChannel.dart';

String decsgerew(String st) => utf8.decode(base64Decode(st));

class TPSDKHelpers {
  static final TPSDKHelpers _instance = TPSDKHelpers._internal();

  factory TPSDKHelpers() {
    return _instance;
  }

  TPSDKHelpers._internal();

  DateTime sj_topon_start = DateTime.now();

  DateTime sj_cloudx_start = DateTime.now();

  int sj_remoteConfigTryCount = 0;

  bool is_ad_suc = false;

  static const _toponBridge = MethodChannel('com.treeperks.growthrecord/topon');
  static const _toponChannelKey = 'tp_topon_channel';
  static const _adjustAppToken = String.fromEnvironment('TP_ADJUST_APP_TOKEN');
  static const _attributionTimeout = Duration(seconds: 2);
  static const _initializationTimeout = Duration(seconds: 10);

  Future<void>? _sdkInitialization;
  TPToponChannel? _toponChannel;
  bool _toponChannelUpdatesEnabled = false;

  Future<void> initSDK() => _sdkInitialization ??= _initAdSdks();

  Future<void> _initAdSdks() async {
    final adjustReady = _initAdjustSDK();
    await Future.wait([
      _initCloudx(),
      _initTopon(adjustReady),
      _reportTbaInstall(),
    ]);
  }

  Future<void> _initCloudx() async {
    sj_cloudx_start = DateTime.now();
    try {
      final result = await CloudX.initialize(
        appKey: 'tqKtgGIx1grs72bae8xfR',
      ).timeout(_initializationTimeout);
      if (result.success) {
        _reportAdInitialization('cloudx', sj_cloudx_start);
        ASLogger.instance.info('CloudX initialized');
      } else {
        ASLogger.instance.warning(
          'CloudX initialization failed: ${result.errorCodeName} ${result.message}',
        );
      }
    } catch (error) {
      ASLogger.instance.warning('CloudX initialization failed: $error');
    }
  }

  Future<void> _initTopon(Future<void> adjustReady) async {
    TPToponChannel? cachedChannel;
    try {
      final prefs = await SharedPreferences.getInstance();
      cachedChannel = TPToponChannel.values
          .asNameMap()[prefs.getString(_toponChannelKey)];
    } catch (error) {
      ASLogger.instance.warning('Unable to read the TopOn channel: $error');
    }
    if (_toponChannel == null && cachedChannel == null) {
      await adjustReady.timeout(_attributionTimeout, onTimeout: () {});
    }

    final channel = _toponChannel ?? cachedChannel ?? TPToponChannel.other;
    sj_topon_start = DateTime.now();
    try {
      // Android applies the custom traffic group before initializing TopOn.
      _toponChannelUpdatesEnabled = true;
      await _toponBridge
          .invokeMethod<void>('initialize', {
            'appId': 'h1hqnb4a2i4840',
            'appKey': 'a9156c213b2217cb46b20be8098a7f123',
            'channel': channel.name,
          })
          .timeout(_initializationTimeout);
      _reportAdInitialization('topon', sj_topon_start);
      ASLogger.instance.info('TopOn initialized');
    } catch (error) {
      ASLogger.instance.warning('TopOn initialization failed: $error');
    }
  }

  void _reportAdInitialization(String source, DateTime startedAt) {
    if (TPRequestHelpers.tba_event_Url.isEmpty) return;
    tp_event_fire('nskdh_ad_initsuc', {
      'ad_source_client': source,
      'ad_init_time': DateTime.now().difference(startedAt).inMilliseconds,
    });
  }

  Future<void> _reportTbaInstall() async {
    if (TPRequestHelpers.tba_event_Url.isEmpty) return;

    try {
      final local = TPLocalProvider.instance;
      final preferences = await SharedPreferences.getInstance();
      final key = local.tp_install_statusName;
      if (preferences.getBool(key) == true) return;
      if (await tp_install_fire()) {
        await preferences.setBool(key, true);
        local.tp_install_status = true;
      }
    } catch (error) {
      ASLogger.instance.warning('TBA install reporting failed: $error');
    }
  }

  Future<void> _setToponChannel(TPToponChannel channel) async {
    try {
      await _toponBridge
          .invokeMethod<void>('setChannel', {'channel': channel.name})
          .timeout(_initializationTimeout);
    } catch (error) {
      ASLogger.instance.warning('TopOn channel update failed: $error');
    }
  }

  void _recordToponChannel(AdjustAttribution attribution) {
    final channel = TPToponChannel.fromAdjust(
      network: attribution.network,
      trackerName: attribution.trackerName,
    );
    if (channel == null || channel == _toponChannel) return;

    _toponChannel = channel;
    unawaited(_saveToponChannel(channel));
    if (_toponChannelUpdatesEnabled) {
      unawaited(_setToponChannel(channel));
    }
  }

  Future<void> _saveToponChannel(TPToponChannel channel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (channel == _toponChannel) {
        await prefs.setString(_toponChannelKey, channel.name);
      }
    } catch (error) {
      ASLogger.instance.warning('TopOn channel cache failed: $error');
    }
  }

  Future<void> _initAdjustSDK() async {
    if (_adjustAppToken.isEmpty) {
      ASLogger.instance.warning('Adjust app token is missing');
      return;
    }

    try {
      final distinctId = await FlutterTbaInfo.instance.getDistinctId().timeout(
        _attributionTimeout,
      );
      final config = AdjustConfig(
        _adjustAppToken,
        kDebugMode ? AdjustEnvironment.sandbox : AdjustEnvironment.production,
      );
      config.attributionCallback = _recordToponChannel;
      Adjust.addGlobalCallbackParameter('customer_user_id', distinctId);
      Adjust.initSdk(config);

      final attribution = await Adjust.getAttributionWithTimeout(
        _attributionTimeout.inMilliseconds,
      );
      if (attribution != null && _toponChannel == null) {
        _recordToponChannel(attribution);
      }
    } catch (error) {
      ASLogger.instance.warning(
        'Adjust initialization or attribution failed: $error',
      );
    }
  }

  // ignore: unused_element
  void _psinitloadFireBase() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    ASLogger.instance.debug("app firebase init");
    ASLogger.instance.debug("app firebase loading");
    try {
      await remoteConfig.fetchAndActivate();

      final gp152_pig_number = remoteConfig
          .getValue('gp152_pig_number')
          .asString();
      if (gp152_pig_number != '') {
        try {
          Map<String, dynamic> jsonMap = json.decode(gp152_pig_number);
          var intModel = TPAppConfig.fromJson(jsonMap);
          TPNumberHelpers().intModel = intModel;
          ASLogger.instance.debug(
            "app firebase remoteconfig gp152_pig_number data $jsonMap",
          );
        } catch (error) {
          ASLogger.instance.debug(
            "app firebase remoteconfig gp152_pig_number error $error",
          );
        }
      }

      final nskdh_ad_config = remoteConfig
          .getValue('nskdh_ad_config')
          .asString();
      if (nskdh_ad_config != '') {
        try {
          Map<String, dynamic> jsonMap = json.decode(nskdh_ad_config);
          // TODO: 广告管理器实现尚未启用。
          // TPPigAds().psPigAdModel = TPAdModel.fromJson(jsonMap);
          // TODO: 广告管理器实现尚未启用。
          // if (TPPigAds().init_suc == true) {
          //             TPPigAds().init(inputAd: TPPigAds().psPigAdModel);
          //           }
          ASLogger.instance.debug(
            "app firebase remoteconfig nskdh_ad_config data $jsonMap",
          );
        } catch (error) {
          ASLogger.instance.debug(
            "app firebase remoteconfig nskdh_ad_config error $error",
          );
        }
      }

      final c152pig_android_fb = remoteConfig
          .getValue("c152pig_android_fb")
          .asString();
      // facebook_init
      if (c152pig_android_fb != '') {
        ASLogger.instance.debug(
          "app firebase remoteconfig c152pig_android_fb data $c152pig_android_fb",
        );
        Map<String, dynamic> jsonMap = json.decode(c152pig_android_fb);
        TPFacebookAnalytics.init(
          appId: jsonMap['app_id'],
          clientToken: jsonMap['client_token'],
          appName: jsonMap['app_name'],
        );
      } else {
        ASLogger.instance.debug('c152pig_android_fb=默认');
        TPFacebookAnalytics.init(
          appId: '3083467831849635',
          clientToken: '7d8a9303f209a20ddf9213b726a897af',
          appName: 'C152GP',
        );
      }

      // 新用户流程中的ad开关
      // 给默认值，确保不存在 Key 时不会报错
      await remoteConfig.setDefaults(<String, dynamic>{
        'new_ad_console': 0, // 默认值
      });
      int new_ad_console = remoteConfig.getValue('new_ad_console').asInt();
      ASLogger.instance.debug(
        "app firebase remoteconfig new_ad_console data $new_ad_console",
      );
      TPLocalProvider.instance.updateint(
        TPLocalProvider.instance.new_ad_consoleName,
        new_ad_console,
      );

      final gp152_control = remoteConfig.getValue('gp152_control').asString();
      if (gp152_control != '') {
        try {
          Map<String, dynamic> jsonMap = json.decode(gp152_control);
          var fkModel = TPFkModel.fromJson(jsonMap);
          TPFKManger().fkModel = fkModel;
          ASLogger.instance.debug(
            "app firebase remoteconfig gp152_control data $jsonMap",
          );
        } catch (error) {
          ASLogger.instance.debug(
            "app firebase remoteconfig gp152_control error $error",
          );
        }
      }

      // 新用户流程中的ad开关
      // 给默认值，确保不存在 Key 时不会报错
      await remoteConfig.setDefaults(<String, dynamic>{
        'quiz_console': 5, // 默认值
      });
      int quiz_console = remoteConfig.getValue('quiz_console').asInt();
      TPLocalProvider.instance.updateint(
        TPLocalProvider.instance.quiz_consoleName,
        quiz_console,
      );
      ASLogger.instance.debug(
        "app firebase remoteconfig new_ad_console data $quiz_console",
      );
    } catch (e, s) {
      ASLogger.instance.error(
        "RemoteConfig fetch error",
        error: e,
        stackTrace: s,
      );
      sj_remoteConfigTryCount += 1;
      if (sj_remoteConfigTryCount <= 60) {
        Future.delayed(Duration(seconds: 1), () {
          _psinitloadFireBase();
        });
      } else {
        // TPPigAds().init();
      }
    }
  }

  // 上报收入
  Future<void> sj_sendintTopOnAdToSdk(Map<String, dynamic> extraMap) async {
    final revenue = extraMap["publisher_revenue"] ?? 0;
    final network = extraMap["network_name"];
    try {
      AdjustAdRevenue adjustAdRevenue = AdjustAdRevenue('topon_sdk');
      adjustAdRevenue.setRevenue(revenue, 'USD');
      adjustAdRevenue.adRevenueNetwork = network;
      Adjust.trackAdRevenue(adjustAdRevenue);
      // await TPFacebookAnalytics.logPurchase(revenue, 'USD');
      ASLogger.instance.debug("af logs:: af revenue success $revenue");
    } catch (e) {
      ASLogger.instance.debug("af logs:: af revenue error $e");
    }
  }
}

class TPFacebookAnalytics {
  static final _channel = MethodChannel(
    "com.example.piggywalletspinearn/facebook",
  );

  /// 初始化 Facebook SDK（动态传入 appId、clientToken、appName）
  static Future<void> init({
    required String appId,
    required String clientToken,
    required String appName,
  }) async {
    await _channel.invokeMethod("initFacebook", {
      "app_id": appId,
      "client_token": clientToken,
      "app_name": appName,
    });
  }

  /// 购买打点（无参数）
  static Future<void> logPurchase(double amount, String currency) async {
    ASLogger.instance.debug('logPurchase');
    await _channel.invokeMethod("logPurchase", {
      "amount": amount,
      "currency": currency,
    });
  }
}
