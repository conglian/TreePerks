import 'TPLogger.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';
import 'package:http/http.dart' as http;
import 'package:treeperks/TPTool/TPLocalProvider.dart';
import 'package:treeperks/TPTool/TPExtensionHelp.dart';
// TODO: 配套源码尚未接入。
// import 'package:pigwalletspineFK/pigwalletspineFK.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../TPModel/TPFkModel.dart';
import 'TPTBAEventTool.dart';

class TPFKManger {
  static final TPFKManger _instance = TPFKManger._internal();

  factory TPFKManger() {
    return _instance;
  }

  TPFKManger._internal();

  TPFkModel fkModel = TPFkModel();

  Future<void> initFKJson() async {
    ASLogger.instance.debug('fkModel=$fkModel');
    if (fkModel.behavior.ad_daily_show == 0) {
      String jsonString = await rootBundle.loadString("tp_control152".jsons());
      ASLogger.instance.debug('risk_control=$jsonString');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      fkModel = TPFkModel.fromJson(jsonMap);
    }
    ASLogger.instance.debug(
      "pigwalletspine fk json = ${fkModel.behavior.ad_daily_show}",
    );
  }

  Future<void> initFK() async {
    // TODO: 风控原生插件尚未接入。
    // tp_checkRoot();
    // TODO: 风控原生插件尚未接入。
    // tp_checkVpn();
    // TODO: 风控原生插件尚未接入。
    // tp_checkSim();
    // TODO: 风控原生插件尚未接入。
    // tp_checkSimulator();
    // TODO: 风控原生插件尚未接入。
    // tp_checkDeveloper();
    // TODO: 风控原生插件尚未接入。
    // tp_checkStore();
    tp_checkIP();
    // TODO: 风控原生插件尚未接入。
    // tp_checkNum();
  }

  // 是否需要打开风控
  Future<bool> tp_checkAllStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String types = 'number';
    // behavior
    bool behavior = await tp_checkUser();
    ASLogger.instance.debug('behavior=$behavior');
    if (behavior) {
      types = 'behavior';
    }
    // number
    bool number = prefs.getBool('tp_fk_number_status') ?? false;
    ASLogger.instance.debug('number=$number');
    if (number) {
      types = 'number';
    }
    // device
    bool device = prefs.getBool('tp_fk_decvice_status') ?? false;
    ASLogger.instance.debug('device=$device');
    if (device) {
      types = 'device';
    }
    if (behavior || number || device) {
      tp_event_fire("nskdh_fk_head_off", {"type": types});
      return true;
    }
    return false;
  }

  // 获取用户异常行为状态
  Future<bool> tp_checkUser() async {
    // 开关未打开
    if (fkModel.ui.behavior == 0) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    ASLogger.instance.debug(
      'TPLocalProvider.instance.tp_fk_ad_short_show2 = ${TPLocalProvider.instance.tp_fk_ad_short_show}',
    );
    // 两次rv间隔时间小于30s，3次以上
    if (prefs.getBool('tp_fk_ad_short_show') == true) {
      return true;
    }
    // RV 从播放到收到关闭回调时间小于20s，3次以上
    if (prefs.getBool('tp_fk_ad_short_close') == true) {
      return true;
    }
    // //现金金额达到提现门槛,视频数少于3次
    if ((prefs.getInt('tp_ad_all_number') ?? 0) <
            fkModel.behavior.wrong_deem_ad_less &&
        (prefs.getInt('tp_dolas_old_number') ?? 0) >= 1000) {
      tp_event_fire('risk_chance', {'risk_from': 'wrong_deem_ad_less'});
      return true;
    }
    // 用户观看90次RV(不包含插屏)，未到提现门槛
    if ((prefs.getInt('tp_ad_reawrd_all_number') ?? 0) >=
            fkModel.behavior.wrong_deem_ad_more &&
        (prefs.getInt('tp_dolas_old_number') ?? 0) < 1000) {
      tp_event_fire('risk_chance', {'risk_from': 'wrong_deem_ad_more'});
      return true;
    }
    return false;
  }

  // 数字联盟
  // TODO: 风控原生插件尚未接入，暂时禁用此调用。
  // tp_checkNum() async {
  //     var numberUnitID = await PigwalletspineFK.instance.tp_getNumberUnitID();
  //     var url = Uri.parse('https://sg-ddi.shuzilm.cn/q');
  //     try {
  //       var response = await http.post(
  //         url,
  //         headers: eventHeader,
  //         body: jsonEncode({
  //           "protocol": 2,
  //           "pkg": await FlutterTbaInfo.instance.getBundleId(),
  //           "did": numberUnitID,
  //         }),
  //       );
  //       ASLogger.instance.debug("upload event [Number] success ${response.body}");
  //
  //       try {
  //         //{"protocol":2,"ver":"1.0.1","err":0,"device_type":0,"normal_times":0,
  //         // "duplicate_times":0,"update_times":1,"recall_times":0}
  //         var json = jsonDecode(response.body);
  //         if (json["err"] == 0 &&
  //             json["device_type"] != 0 &&
  //             fkModel.ui.number == 1) {
  //           tp_event_fire('risk_chance', {'risk_from': 'number'});
  //           await TPLocalProvider.instance.updateBool(
  //             TPLocalProvider.instance.tp_fk_number_statusName,
  //             true,
  //           );
  //         } else {
  //           await TPLocalProvider.instance.updateBool(
  //             TPLocalProvider.instance.tp_fk_number_statusName,
  //             false,
  //           );
  //         }
  //       } catch (e) {
  //         await TPLocalProvider.instance.updateBool(
  //           TPLocalProvider.instance.tp_fk_number_statusName,
  //           false,
  //         );
  //       }
  //     } catch (e) {
  //       await TPLocalProvider.instance.updateBool(
  //         TPLocalProvider.instance.tp_fk_number_statusName,
  //         false,
  //       );
  //       ASLogger.instance.debug("upload event [Number] faild");
  //     }
  //   }

  Map<String, String> eventHeader = {'Content-Type': 'application/json'};

  // 设备 Ip
  Future<void> tp_checkIP() async {
    var url = Uri.parse('https://ip-prod.piggywalletspinfunpro.com/api/clion');
    try {
      var response = await http.post(
        url,
        headers: eventHeader,
        body: jsonEncode({
          "aduck": await FlutterTbaInfo.instance.getAndroidId(),
        }),
      );
      ASLogger.instance.debug("upload event [IP] success ${response.body}");
      //{"code":200,"msg":"Success","data":{"blion":false}}
      var result = TPBoomUniqueStringUtil.decrypt(response.body, 45);
      ASLogger.instance.debug("upload event [IP] success $result");
      try {
        var bfrog = jsonDecode(result)["data"]["bfrog"];
        if (bfrog && fkModel.device.contains('ip') && fkModel.ui.device == 1) {
          tp_event_fire('risk_chance', {'risk_from': 'ip'});
          await TPLocalProvider.instance.updateBool(
            TPLocalProvider.instance.tp_fk_ip_statusName,
            true,
          );
        }
      } catch (e) {
        await TPLocalProvider.instance.updateBool(
          TPLocalProvider.instance.tp_fk_ip_statusName,
          false,
        );
      }
    } catch (e) {
      await TPLocalProvider.instance.updateBool(
        TPLocalProvider.instance.tp_fk_ip_statusName,
        false,
      );
      ASLogger.instance.debug("upload event [IP] faild");
    }
  }

  // TODO: 风控原生插件尚未接入，暂时禁用此调用。
  // tp_add_tabsession_custom() async {
  //     bool root = await tp_checkRoot();
  //     bool vpn = await tp_checkVpn();
  //     bool sim = await tp_checkSim();
  //     bool simulator = await tp_checkSimulator();
  //     bool developer = await tp_checkDeveloper();
  //     bool googleplay = await tp_checkStore();
  //     Map<String, dynamic> customer = {
  //       'root': root ? 1 : 0,
  //       'vpn': vpn ? 1 : 0,
  //       'sim': sim ? 1 : 0,
  //       'simulator': simulator ? 1 : 0,
  //       'developer': developer ? 1 : 0,
  //       'googleplay': googleplay ? 1 : 0,
  //     };
  //     tp_event_fire('session_custom', customer);
  //   }

  // TODO: 风控原生插件尚未接入，暂时禁用此调用。
  // Future<bool> tp_checkRoot() async {
  //     var result = await PigwalletspineFK.instance.tp_root();
  //     if (fkModel.ui.device == 0) {
  //       return false;
  //     }
  //     if (result && fkModel.device.contains('root')) {
  //       tp_event_fire('risk_chance', {'risk_from': 'root'});
  //       TPLocalProvider.instance.updateBool(
  //         TPLocalProvider.instance.tp_fk_decvice_statusName,
  //         true,
  //       );
  //       return true;
  //     }
  //     return false;
  //   }

  // TODO: 风控原生插件尚未接入，暂时禁用此调用。
  // Future<bool> tp_checkVpn() async {
  //     var result = await PigwalletspineFK.instance.tp_vpn();
  //     if (fkModel.ui.device == 0) {
  //       return false;
  //     }
  //     if (result && fkModel.device.contains('vpn')) {
  //       tp_event_fire('risk_chance', {'risk_from': 'vpn'});
  //       TPLocalProvider.instance.updateBool(
  //         TPLocalProvider.instance.tp_fk_decvice_statusName,
  //         true,
  //       );
  //       return true;
  //     }
  //     return false;
  //   }

  // TODO: 风控原生插件尚未接入，暂时禁用此调用。
  // Future<bool> tp_checkSim() async {
  //     var result = await PigwalletspineFK.instance.tp_sim();
  //     if (fkModel.ui.device == 0) {
  //       return false;
  //     }
  //     if (!result && fkModel.device.contains('sim')) {
  //       tp_event_fire('risk_chance', {'risk_from': 'sim'});
  //       TPLocalProvider.instance.updateBool(
  //         TPLocalProvider.instance.tp_fk_decvice_statusName,
  //         true,
  //       );
  //       return true;
  //     }
  //     return false;
  //   }

  // TODO: 风控原生插件尚未接入，暂时禁用此调用。
  // Future<bool> tp_checkSimulator() async {
  //     var result = await PigwalletspineFK.instance.tp_simulator();
  //     if (fkModel.ui.device == 0) {
  //       return false;
  //     }
  //     if (result && fkModel.device.contains('simulator')) {
  //       tp_event_fire('risk_chance', {'risk_from': 'simulator'});
  //       TPLocalProvider.instance.updateBool(
  //         TPLocalProvider.instance.tp_fk_decvice_statusName,
  //         true,
  //       );
  //       return true;
  //     }
  //     return false;
  //   }

  // TODO: 风控原生插件尚未接入，暂时禁用此调用。
  // Future<bool> tp_checkDeveloper() async {
  //     var result = await PigwalletspineFK.instance.tp_developer();
  //     if (fkModel.ui.device == 0) {
  //       return false;
  //     }
  //     if (result && fkModel.device.contains('developer')) {
  //       tp_event_fire('risk_chance', {'risk_from': 'developer'});
  //       TPLocalProvider.instance.updateBool(
  //         TPLocalProvider.instance.tp_fk_decvice_statusName,
  //         true,
  //       );
  //       return true;
  //     }
  //     return false;
  //   }

  // TODO: 风控原生插件尚未接入，暂时禁用此调用。
  // Future<bool> tp_checkStore() async {
  //     var result = await PigwalletspineFK.instance.tp_store();
  //     if (fkModel.ui.device == 0) {
  //       return false;
  //     }
  //     if (!result && fkModel.device.contains('googleplay')) {
  //       tp_event_fire('risk_chance', {'risk_from': 'googleplay'});
  //       TPLocalProvider.instance.updateBool(
  //         TPLocalProvider.instance.tp_fk_decvice_statusName,
  //         true,
  //       );
  //       return true;
  //     }
  //     return false;
  //   }
}
