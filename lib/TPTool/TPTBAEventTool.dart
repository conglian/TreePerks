import 'TPLogger.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tba_info/flutter_tba_info.dart';

void tp_session_fire() async {
  var baseBody = await TPRequestHelpers().baseBody();
  baseBody["chinook"] = {};
  TPRequestHelpers().post(baseBody, 2);
}

void tp_ad_fire(Map<String, dynamic> body) async {
  var baseBody = await TPRequestHelpers().baseBody();
  baseBody["braid"] = body;
  TPRequestHelpers().post(baseBody, 3);
}

void tp_event_fire(String name, Map<String, dynamic> body) async {
  var baseBodys = await TPRequestHelpers().baseBody();
  baseBodys["infima"] = name;
  baseBodys['hermetic'] = body;
  TPRequestHelpers().post(baseBodys, 0);
}

Future<bool> tp_install_fire() async {
  var baseBody = await TPRequestHelpers().baseBody();
  var map = await FlutterTbaInfo.instance.getReferrerMap();
  baseBody["material"] = map['build'];
  baseBody["erode"] = map['referrer_url'];
  baseBody["lea"] = map['install_version'];
  baseBody["wile"] = map['user_agent'];
  baseBody["freight"] = 'strewn';
  baseBody["grovel"] = map['referrer_click_timestamp_seconds'];
  baseBody["doberman"] = map['install_begin_timestamp_seconds'];
  baseBody["defy"] = map['referrer_click_timestamp_server_seconds'];
  baseBody["chair"] = map['install_begin_timestamp_server_seconds'];
  baseBody["espouse"] = map['install_first_seconds'];
  baseBody["ojibwa"] = map['last_update_seconds'];
  baseBody["infima"] = 'handsome';
  return await TPRequestHelpers().post(baseBody, 1) != null;
}

class TPRequestHelpers {
  static final TPRequestHelpers _instance = TPRequestHelpers._internal();

  factory TPRequestHelpers() {
    return _instance;
  }

  TPRequestHelpers._internal();

  static String cloak_Url =
      "https://actress.piggywalletspinfunpro.com/rueful/gloomy";

  // static String tba_event_Url_test =
  //     "https://test-appian.piggywalletspinfunpro.com/sextet/tiresome/youth";

  static String tba_event_Url_release =
      "https://appian.piggywalletspinfunpro.com/thrust/herschel/kochab";

  static String tba_event_Url = const String.fromEnvironment(
    'TP_TBA_EVENT_URL',
  );

  final Map<String, String> normalHeader = {'Content-Type': 'application/json'};

  Map<String, String> eventHeader = {'Content-Type': 'application/json'};

  Future<dynamic> getCloak() async {
    var url = Uri.parse(
      "$cloak_Url?cab=${await FlutterTbaInfo.instance.getBundleId()}&afghan=sarasota&merry=${await FlutterTbaInfo.instance.getAppVersion()}&archaic=${DateTime.now().millisecondsSinceEpoch}",
    );
    ASLogger.instance.debug("scratch play land config request $url");
    try {
      var response = await http.get(url, headers: normalHeader);
      return _handleResponse(response);
    } catch (e) {
      ASLogger.instance.debug("upload event [cloak] faild error $e");
    }
  }

  Future<dynamic> post(dynamic data, int type) async {
    var eventName = "";
    if (type == 0) {
      eventName = "event";
    } else if (type == 1) {
      eventName = "install";
    } else if (type == 2) {
      eventName = "session";
    } else {
      eventName = "ad";
    }
    var url = Uri.parse(tba_event_Url);
    ASLogger.instance.debug("upload event [$eventName] url $url \n $data");
    try {
      var response = await http.post(
        url,
        headers: eventHeader,
        body: jsonEncode(data),
      );
      ASLogger.instance.debug(
        "upload event [$eventName] success ${response.body}",
      );
      // ASLogger.instance.debug("upload event [${eventName}] success ${response.body}");
      return _handleResponse(response);
    } catch (e) {
      ASLogger.instance.debug("upload event [$eventName] faild error $e");
      // throw Exception('Failed to perform POST request: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  void _refreshHeader() async {
    eventHeader = {'Content-Type': 'application/json'};
  }

  void init() {
    _refreshHeader();
  }
}

// request parmerters
extension TPRequestHelpersExtension on TPRequestHelpers {
  Future<String> getConfigQueryString() async {
    var queryBody = {
      "walter": await FlutterTbaInfo.instance.getBundleId(),
      "rancid": 'perky',
      "advise": await FlutterTbaInfo.instance.getAppVersion(),
    };
    ASLogger.instance.debug('queryBody=$queryBody');
    return Uri(queryParameters: queryBody).query;
  }

  Future<Map<String, dynamic>> baseBody() async {
    Map<String, dynamic> baseBody = {};

    Map<String, dynamic> sheppard = {
      "walter": await FlutterTbaInfo.instance.getBundleId(),
      'advise': await FlutterTbaInfo.instance.getAppVersion(),
      "sora": await FlutterTbaInfo.instance.getLogId(),
      "digamma": await FlutterTbaInfo.instance.getDeviceModel(),
    };
    baseBody['sheppard'] = sheppard;

    Map<String, dynamic> smutty = {
      "rancid": 'perky',
      'barr': await FlutterTbaInfo.instance.getDistinctId(),
      'plaguey': await FlutterTbaInfo.instance.getBrand(),
      "moliere": await FlutterTbaInfo.instance.getOperator(),
      'operant': await FlutterTbaInfo.instance.getAndroidId(),
    };
    baseBody['smutty'] = smutty;

    Map<String, dynamic> chromium = {
      'basso': DateTime.now().millisecondsSinceEpoch,
      'glamour': await FlutterTbaInfo.instance.getManufacturer(),
      'pyle': await FlutterTbaInfo.instance.getOsVersion(),
      "complain": await FlutterTbaInfo.instance.getNetworkType(),
      'dyadic': await FlutterTbaInfo.instance.getSystemLanguage(),
      "symphony": await FlutterTbaInfo.instance.getGaid(),
      'prickle': await FlutterTbaInfo.instance.getOsCountry(),
    };
    baseBody['chromium'] = chromium;
    return baseBody;
  }
}
