// TODO: 配套源码尚未接入。
// import 'TPPaymentConfig.dart';
// TODO: 配套源码尚未接入。
// import 'TPLogger.dart';
// TODO: 配套源码尚未接入。
// import 'dart:async';
// TODO: 配套源码尚未接入。
// import 'dart:io';
// TODO: 配套源码尚未接入。
// import 'package:flutter/cupertino.dart';
// TODO: 配套源码尚未接入。
// import 'package:shared_preferences/shared_preferences.dart';
// TODO: 配套源码尚未接入。
// import 'package:flutter_lifecycle_detector/flutter_lifecycle_detector.dart';
// TODO: 配套源码尚未接入。
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// TODO: 配套源码尚未接入。
// import 'package:treeperks/TPDialog/TPDialog.dart';
// TODO: 配套源码尚未接入。
// import 'package:treeperks/TPHome/TPHome.dart';
// TODO: 配套源码尚未接入。
// import 'package:treeperks/TPPigVC/TPPigHome.dart';
// TODO: 配套源码尚未接入。
// import 'package:treeperks/TPTool/TPLocalProvider.dart';
// TODO: 配套源码尚未接入。
// import 'package:treeperks/TPTool/TPAdManger.dart';
// TODO: 配套源码尚未接入。
// import 'package:treeperks/TPTool/TPExtensionHelp.dart';
// TODO: 配套源码尚未接入。
// import '../TPBase/TPTbaBar.dart';
// TODO: 配套源码尚未接入。
// import '../main.dart';
// TODO: 配套源码尚未接入。
// import 'TPFKManger.dart';
// TODO: 配套源码尚未接入。
// import 'TPTBAEventTool.dart';

// TODO: 自定义通知插件和业务页面未接入，暂时保留实现。
// class TPNoticeHelp with WidgetsBindingObserver {
//   static final TPNoticeHelp _instance = TPNoticeHelp._internal();
//
//   factory TPNoticeHelp() {
//     return _instance;
//   }
//
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   TPNoticeHelp._internal();
//
//   bool _initialized = false;
//   Future<bool>? _permissionRequest;
//
//   // 冷启动由启动页和首页共享同一次系统权限申请，避免拒绝后连续重复弹窗。
//   Future<bool> requestPermissionOnce() =>
//       _permissionRequest ??= AndroidFlutterLocalNotificationsPlugin()
//           .requestNotificationsPermission()
//           .then((value) => value ?? false);
//   bool _ready = false;
//   bool _notificationsEnabled = false;
//   Future<void> _permissionRefresh = Future.value();
//
//   Future<void> initNotice(BuildContext context) async {
//     if (_initialized) return;
//     _initialized = true;
//     WidgetsBinding.instance.addObserver(this);
//
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('tp_logo'); // 不加 .png
//
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (response) {
//         ASLogger.instance.debug('nf click response:${response}');
//         final String? payload = response.payload;
//         tp_event_fire('inform_c', {'type': payload ?? ''});
//         if (payload == null) return;
//       },
//     );
//
//     NotificationAppLaunchDetails? notificationAppLaunchDetails =
//         await AndroidFlutterLocalNotificationsPlugin()
//             .getNotificationAppLaunchDetails();
//     ASLogger.instance.debug(
//       '=initNotification====getNotificationAppLaunchDetails==notificationAppLaunchDetails:$notificationAppLaunchDetails=',
//     );
//
//     if (notificationAppLaunchDetails != null) {
//       NotificationResponse? notificationResponse =
//           notificationAppLaunchDetails.notificationResponse;
//       bool didNotificationLaunchApp =
//           notificationAppLaunchDetails.didNotificationLaunchApp;
//       if (didNotificationLaunchApp) {
//         tp_event_fire('inform_c', {
//           'type': notificationResponse?.payload ?? '',
//         });
//       }
//     }
//
//     final nfPermission =
//         await AndroidFlutterLocalNotificationsPlugin()
//                 .areNotificationsEnabled() ==
//             true ||
//         await requestPermissionOnce();
//     _notificationsEnabled = nfPermission;
//     if (_notificationsEnabled) {
//       tp_event_fire('push_status', {});
//     } else {
//       ASLogger.instance.debug("nf no permission");
//       if (context.mounted)
//         context.tipShow(TPPopTipsToolDialog(adStatus: .noticeOpen));
//     }
//     _initLifecycleListener();
//     unawaited(syncFcmTopics());
//     if (_notificationsEnabled) await _scheduleFutureNotifications();
//     await _spinitNotificationCount(flutterLocalNotificationsPlugin);
//     _ready = true;
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (_ready && state == AppLifecycleState.resumed)
//       refreshNotificationPermission();
//   }
//
//   /// 从系统设置授权后只恢复未来任务，不读取、重放历史通知。
//   Future<void> refreshNotificationPermission() {
//     _permissionRefresh = _permissionRefresh.then((_) async {
//       try {
//         final enabled =
//             await AndroidFlutterLocalNotificationsPlugin()
//                 .areNotificationsEnabled() ??
//             false;
//         final granted = enabled && !_notificationsEnabled;
//         _notificationsEnabled = enabled;
//         if (granted) {
//           unawaited(syncFcmTopics());
//           await _scheduleFutureNotifications();
//         }
//       } catch (error) {
//         ASLogger.instance.debug(
//           'Notification permission refresh failed: $error',
//         );
//       }
//     });
//     return _permissionRefresh;
//   }
//
//   Future<void> _scheduleFutureNotifications() async {
//     await startSJForegroundService();
//     await _repeatNotification1();
//     await _repeatNotification2();
//     await _repeatNotification3();
//     await _repeatNotification4();
//     await _showUnlockNotification();
//     await _showScreenOnNotification();
//     await showSJNotificationMediaStyle1();
//     await showSJNotificationMediaStyle2();
//     await showSJNotificationMediaStyle3();
//     await showSJNotificationMediaStyle4();
//   }
//
//   _spinitNotificationCount(
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
//   ) async {
//     try {
//       int locals = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("noti1");
//       ASLogger.instance.debug("==initNotificationCount==localcount:$locals==");
//       if (locals > 0) {
//         for (int i = 0; i < locals; i++) {
//           tp_event_fire('inform_p', {'type': "noti1"});
//         }
//       }
//       int locals2 = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("noti2");
//       ASLogger.instance.debug("==initNotificationCount==localcount:$locals2==");
//       if (locals2 > 0) {
//         for (int i = 0; i < locals2; i++) {
//           tp_event_fire('inform_p', {'type': "noti2"});
//         }
//       }
//       int locals3 = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("noti3");
//       ASLogger.instance.debug("==initNotificationCount==localcount:$locals3==");
//       if (locals3 > 0) {
//         for (int i = 0; i < locals3; i++) {
//           tp_event_fire('inform_p', {'type': "noti3"});
//         }
//       }
//       int locals4 = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("noti4");
//       ASLogger.instance.debug("==initNotificationCount==localcount:$locals4==");
//       if (locals4 > 0) {
//         for (int i = 0; i < locals4; i++) {
//           tp_event_fire('inform_p', {'type': "noti4"});
//         }
//       }
//       int fcms = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("fcm");
//       ASLogger.instance.debug("==initNotificationCount==localcount:$fcms==");
//       if (fcms > 0) {
//         for (int i = 0; i < fcms; i++) {
//           tp_event_fire('inform_p', {'type': "fcm"});
//         }
//       }
//
//       int unlocks = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("unlock");
//       ASLogger.instance.debug("==initNotificationCount==localcount:$unlocks==");
//       if (unlocks > 0) {
//         for (int i = 0; i < unlocks; i++) {
//           tp_event_fire('inform_p', {'type': "unlock"});
//         }
//       }
//
//       int screenon = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("screenon");
//       ASLogger.instance.debug(
//         "==initNotificationCount==localcount:$screenon==",
//       );
//       if (screenon > 0) {
//         for (int i = 0; i < screenon; i++) {
//           tp_event_fire('inform_p', {'type': "screenon"});
//         }
//       }
//
//       int foreground = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("foreground");
//       ASLogger.instance.debug(
//         "==initNotificationCount==localcount:$foreground==",
//       );
//       if (foreground > 0) {
//         for (int i = 0; i < foreground; i++) {
//           tp_event_fire('inform_p', {'type': "foreground"});
//         }
//       }
//
//       int media = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("media1");
//       ASLogger.instance.debug("==initNotificationCount==localcount:$media==");
//       if (media > 0) {
//         for (int i = 0; i < media; i++) {
//           tp_event_fire('inform_p', {'type': "media"});
//         }
//       }
//
//       int media2 = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("media2");
//       ASLogger.instance.debug("==initNotificationCount==localcount:$media==");
//       if (media2 > 0) {
//         for (int i = 0; i < media2; i++) {
//           tp_event_fire('inform_p', {'type': "media"});
//         }
//       }
//
//       int media3 = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("media3");
//       ASLogger.instance.debug("==initNotificationCount==localcount:$media==");
//       if (media3 > 0) {
//         for (int i = 0; i < media3; i++) {
//           tp_event_fire('inform_p', {'type': "media"});
//         }
//       }
//
//       int media4 = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("media4");
//       ASLogger.instance.debug("==initNotificationCount==localcount:$media==");
//       if (media4 > 0) {
//         for (int i = 0; i < media4; i++) {
//           tp_event_fire('inform_p', {'type': "media"});
//         }
//       }
//     } catch (e) {
//       ASLogger.instance.debug("===initNotificationCount==error:$e=");
//     }
//   }
//
//   Future<void> setNoticeStatus() async {
//     final granted = await requestPermissionOnce();
//     if (granted) {
//       tp_event_fire('push_status', {});
//       if (_ready)
//         await refreshNotificationPermission();
//       else
//         _notificationsEnabled = true;
//     } else {
//       _notificationsEnabled = false;
//     }
//   }
//
//   // 前台服务
//   Future<void> startSJForegroundService() async {
//     const channelId = 'pigwalletForeground';
//     const brand = 'paypal';
//     final balance = TPPaymentConfig.money(TPLocalProvider.instance.tp_dolas_number);
//     const channelName = 'Wallet balance';
//     final title = '$balance is waiting in your wallet.';
//     const withdraw = 'Withdraw';
//     final plugin = AndroidFlutterLocalNotificationsPlugin();
//     // Reuse the channel ID so system notification preferences are preserved.
//     await plugin.createNotificationChannel(
//       AndroidNotificationChannel(
//         channelId,
//         channelName,
//         importance: Importance.min,
//       ),
//     );
//     await plugin.startForegroundService(
//       1200,
//       title,
//       null,
//       notificationDetails: AndroidNotificationDetails(
//         channelId,
//         channelName,
//         ongoing: true,
//         importance: Importance.min,
//         priority: Priority.min,
//         styleInformation: ForegroundStyleInformation(
//           value: balance,
//           image: 'tp_freground',
//           logo: 'tp_foreground_$brand',
//           button: withdraw,
//         ),
//       ),
//       payload: 'foreground',
//     );
//   }
//
//   // 媒体通知
//   Future<void> showSJNotificationMediaStyle1() async {
//     //自定义通知ID
//     final int id = 478;
//     final randomMotivation = TPStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '152notice0',
//       'PigWalletSPine0',
//       styleInformation: MediaStyleInformation(
//         //支持网络图片链接
//         image: 'tp_sm_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'tp_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//       id,
//       title,
//       body,
//       //间隔时长根据需求设置
//       const Duration(minutes: 40),
//       notificationDetails: details,
//       scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: "Media1",
//     );
//   }
//
//   Future<void> showSJNotificationMediaStyle2() async {
//     //自定义通知ID
//     final int id = 2488;
//     final randomMotivation = TPStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '152notice21',
//       'PigWalletSPine21',
//       styleInformation: MediaStyleInformation(
//         //支持网络图片链接
//         image: 'tp_sm_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'tp_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//       id,
//       title,
//       body,
//       //间隔时长根据需求设置
//       const Duration(minutes: 80),
//       notificationDetails: details,
//       scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: "Media2",
//     );
//   }
//
//   Future<void> showSJNotificationMediaStyle3() async {
//     //自定义通知ID
//     final int id = 2914;
//     final randomMotivation = TPStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '152notice31',
//       'PigWalletSPine31',
//       styleInformation: MediaStyleInformation(
//         //支持网络图片链接
//         image: 'tp_sm_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'tp_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//       id,
//       title,
//       body,
//       //间隔时长根据需求设置
//       const Duration(minutes: 160),
//       notificationDetails: details,
//       scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: "Media3",
//     );
//   }
//
//   Future<void> showSJNotificationMediaStyle4() async {
//     //自定义通知ID
//     final int id = 1020;
//     final randomMotivation = TPStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '152notice41',
//       'PigWalletSPine41',
//       styleInformation: MediaStyleInformation(
//         //支持网络图片链接
//         image: 'tp_sm_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'tp_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//       id,
//       title,
//       body,
//       //间隔时长根据需求设置
//       const Duration(minutes: 190),
//       notificationDetails: details,
//       scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: "Media4",
//     );
//   }
//
//   // Future<void> _tapMediasNotice(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//   //
//   //   await flutterLocalNotificationsPlugin.cancel(3744);
//   //
//   //   final NotificationDetails media = NotificationDetails(
//   //     android: AndroidNotificationDetails(
//   //       'scratchjoy Media',
//   //       'scratchjoy',
//   //       styleInformation: MediaStyleInformation(image: 'tp_sm_logo'),
//   //     ),
//   //   );
//   //
//   //   final int id = 3744;
//   //   final randomMotivation = TPStepMotivationManager.getRandomMotivation();
//   //   final String title = randomMotivation.title;
//   //   final String body = randomMotivation.body;
//   //   await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//   //       id,
//   //       title,
//   //       body,
//   //       //间隔时长根据需求设置
//   //       Duration(minutes: 30),
//   //       notificationDetails: media.android,
//   //       scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//   //       payload: "media"
//   //   );
//   // }
//
//   // 本地通知
//   Future<void> _repeatNotification1() async {
//     //自定义通知ID
//     final int id = 5290;
//     final randomMotivation = TPStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '152notice1',
//       'PigWalletSPine1',
//       styleInformation: BeautyStyleInformation(
//         title: title,
//         body: body,
//         image: 'tp_notice_big',
//         button: 'Withdraw',
//         appIcon: 'tp_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'tp_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//       id,
//       title,
//       body,
//       //间隔时长根据需求设置
//       const Duration(minutes: 30),
//       notificationDetails: details,
//       scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: "noti1",
//     );
//   }
//
//   Future<void> _repeatNotification2() async {
//     //自定义通知ID
//     final int id = 4562;
//     final randomMotivation = TPStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '152notice2',
//       'PigWalletSPine2',
//       styleInformation: BeautyStyleInformation(
//         title: title,
//         body: body,
//         image: 'tp_notice_big',
//         button: 'Withdraw',
//         appIcon: 'tp_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'tp_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//       id,
//       title,
//       body,
//       //间隔时长根据需求设置
//       const Duration(minutes: 60),
//       notificationDetails: details,
//       scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: "noti2",
//     );
//   }
//
//   Future<void> _repeatNotification3() async {
//     //自定义通知ID
//     final int id = 6552;
//     final randomMotivation = TPStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '152notice3',
//       'PigWalletSPine3',
//       styleInformation: BeautyStyleInformation(
//         title: title,
//         body: body,
//         image: 'tp_notice_big',
//         button: 'Withdraw',
//         appIcon: 'tp_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'tp_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//       id,
//       title,
//       body,
//       //间隔时长根据需求设置
//       const Duration(minutes: 90),
//       notificationDetails: details,
//       scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: "noti3",
//     );
//   }
//
//   Future<void> _repeatNotification4() async {
//     //自定义通知ID
//     final int id = 9175;
//     final randomMotivation = TPStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '152notice4',
//       'PigWalletSPine4',
//       styleInformation: BeautyStyleInformation(
//         title: title,
//         body: body,
//         image: 'tp_notice_big',
//         button: 'Withdraw',
//         appIcon: 'tp_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'tp_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//       id,
//       title,
//       body,
//       //间隔时长根据需求设置
//       const Duration(minutes: 120),
//       notificationDetails: details,
//       scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       payload: "noti4",
//     );
//   }
//
//   Future<void> _topicSync = Future.value();
//
//   Future<void> syncFcmTopics() {
//     _topicSync = _topicSync.then((_) async {
//       try {
//         final plugin = AndroidFlutterLocalNotificationsPlugin();
//         final prefs = await SharedPreferences.getInstance();
//         const topics = ['c152fcm_piggy', 'c152fcm_piggy_two'];
//         final active =
//             (prefs.getStringList('tp_fcm_topics') ?? const <String>[])
//                 .toSet();
//         for (final topic
//             in active.where((topic) => !topics.contains(topic)).toList()) {
//           if (await plugin.unsubscribeFromTopic(topic) == true) {
//             active.remove(topic);
//             await prefs.setStringList('tp_fcm_topics', active.toList());
//           }
//         }
//         for (var i = 0; i < topics.length; i++) {
//           if (await _subscribeFcmTopic(topics[i], secondary: i == 1) == true) {
//             active.add(topics[i]);
//             await prefs.setStringList('tp_fcm_topics', active.toList());
//           }
//         }
//       } catch (error) {
//         ASLogger.instance.debug('FCM topic sync failed: $error');
//       }
//     });
//     return _topicSync;
//   }
//
//   Future<bool?> _subscribeFcmTopic(String topic, {bool secondary = false}) {
//     return AndroidFlutterLocalNotificationsPlugin().subscribeToTopic(
//       topic,
//       AndroidNotificationDetails(
//         topic,
//         secondary ? 'PigWalletSPine2' : 'PigWalletSPine',
//         styleInformation: BeautyStyleInformation(
//           title: '',
//           body: '',
//           image: '',
//           button: secondary ? 'Claim' : 'Withdraw',
//           appIcon: 'tp_logo',
//         ),
//         priority: Priority.high,
//         importance: Importance.high,
//         icon: 'tp_sm_logo',
//       ),
//     );
//   }
//
//   Future<void> _showUnlockNotification() async {
//     //自定义通知ID
//     final int ids = 2829;
//     final randomMotivation = TPStepMotivationManager.getRandomMotivation();
//     TPStepMotivation randomMotivation2 =
//         TPStepMotivationManager.getRandomMotivation();
//     ;
//     await AndroidFlutterLocalNotificationsPlugin().showBroadcastNotification(
//       ids,
//       randomMotivation.title,
//       randomMotivation.body,
//       //两次发送解锁通知的间隔，根据需求设置
//       const Duration(seconds: 30),
//       'android.intent.action.USER_PRESENT',
//       AndroidNotificationDetails(
//         '152PigWalletSPines',
//         'PigWalletSPines',
//         priority: Priority.high,
//         importance: Importance.high,
//         icon: 'tp_sm_logo',
//         styleInformation: BeautyStyleInformation(
//           title: randomMotivation2.title,
//           body: randomMotivation2.body,
//           image: 'tp_notice_big',
//           button: 'Withdraw',
//           appIcon: 'tp_logo',
//         ),
//         //“groupKey”：防止通知被系统折叠
//         groupKey: "$ids",
//       ),
//       'unlock',
//     );
//   }
//
//   Future<void> _showScreenOnNotification() async {
//     //自定义通知ID
//     final int ids = 1029;
//     final randomMotivation = TPStepMotivationManager.getRandomMotivation();
//     TPStepMotivation randomMotivation2 =
//         TPStepMotivationManager.getRandomMotivation();
//     ;
//     await AndroidFlutterLocalNotificationsPlugin().showBroadcastNotification(
//       ids,
//       randomMotivation.title,
//       randomMotivation.body,
//       //两次发送解锁通知的间隔，根据需求设置
//       const Duration(seconds: 30),
//       'android.intent.action.SCREEN_ON',
//       AndroidNotificationDetails(
//         '152PigWalletSPinescreen',
//         'PigWalletSPineScreen',
//         priority: Priority.high,
//         importance: Importance.high,
//         icon: 'tp_sm_logo',
//         styleInformation: BeautyStyleInformation(
//           title: randomMotivation2.title,
//           body: randomMotivation2.body,
//           image: 'tp_notice_big',
//           button: 'Withdraw',
//           appIcon: 'tp_logo',
//         ),
//         //“groupKey”：防止通知被系统折叠
//         groupKey: "$ids",
//       ),
//       'screenon',
//     );
//   }
//
//   bool _lifecycleListening = false;
//
//   Future<void> _initLifecycleListener() async {
//     if (_lifecycleListening) return;
//     _lifecycleListening = true;
//
//     FlutterLifecycleDetector().onBackgroundChange.listen((isBackground) async {
//       /// `isBackground` is true => background
//       /// `isBackground` is false => foreground
//       ASLogger.instance.debug('Status background $isBackground');
//       if (isBackground == true) {
//         ASLogger.instance.debug('App进入后台');
//         // SJAudioUtils().pauseBGM();
//         TPFKManger().tp_add_tabsession_custom();
//         // 执行后台逻辑
//         tp_session_fire();
//         tp_event_fire('session_back_get', {
//           '"pak_version': TPLocalProvider.instance.tp_login_status ? 1 : 0,
//         });
//       } else {
//         ASLogger.instance.debug('App进入前台');
//         syncFcmTopics();
//         // if (TPLocalProvider.instance.tp_bg_music && !SJJoyAds().someAdIsShowing()){
//         //   SJAudioUtils().playBGM();
//         // }
//         TPFKManger().tp_add_tabsession_custom();
//         tp_event_fire('session_front_get', {
//           '"pak_version': TPLocalProvider.instance.tp_login_status ? 1 : 0,
//         });
//         // 执行前台逻辑
//         tp_session_fire();
//         if (!TPPigAds().is_showAd) {
//           TPPigAds().tp_showAd(
//             homeKey.currentState!.context,
//             'nskdh_launch',
//             showDialog: false,
//             onCacheResponse: (onCacheResponse) {},
//             adDidClosed: (adDidClosed) {},
//           );
//         }
//       }
//     });
//   }
// }

/// 步行激励文案数据模型
class TPStepMotivation {
  final String title;
  final String body;

  TPStepMotivation({required this.title, required this.body});
}

/// 步行激励文案工具类
class TPStepMotivationManager {
  // 文案数据列表
  static List<TPStepMotivation> get _motivations => [
    TPStepMotivation(
      title: "Piggy Almost Full!",
      body: "You’ve saved \$4.80—cash out before it spills!",
    ),
    TPStepMotivation(
      title: "Cash-Out Time 🎉",
      body: "Spin & play—your balance is ready to grab!",
    ),
    TPStepMotivation(
      title: "Your Payout Is Ready! 💰",
      body:
          "Piggy bank is full and ready to pop—open the app to collect your cash.",
    ),
    TPStepMotivation(
      title: "Advertiser Just Paid You! 🎁",
      body: "Tap to feed your piggy & claim today’s payout.",
    ),
    TPStepMotivation(
      title:
          " "
          "Balance Near Max 💵",
      body: "Almost full—withdraw before it’s gone!",
    ),
    // TPStepMotivation(
    //   title: "Congrats! You've Earned a lot! 🎉",
    //   body: "Another \$ 500 cash in your pocket! Keep playing for more!",
    // ),
    // TPStepMotivation(
    //   title: "Feeling Lucky Today? 🍀",
    //   body: "Come and try your luck, win a fortune!",
    // ),
    // TPStepMotivation(
    //   title: "Pending withdraw amount💰",
    //   body: "\$500 has arrived in your account",
    // ),
    // TPStepMotivation(
    //   title: "Your Next Cash Reward is Ready! 👉",
    //   body: "Just a few more games to claim your \$800 cash!",
    // ),
    // TPStepMotivation(
    //   title: "\$1,000,000 Spectacular",
    //   body: "🎰 Congrats! Your \$1,000,000 Spectacular ticket is activated!",
    // ),
    // TPStepMotivation(
    //   title: "💥Fast \$50s – Speed Boost Activated!",
    //   body: "💸 Your Fast \$50s ticket is ready!",
    // ),
    // TPStepMotivation(
    //   title: "💰Multiplier Rewards Available!",
    //   body: "24-hour special: Next multiplier DOUBLED!",
    // ),
  ];

  /// 随机获取一条激励文案
  static TPStepMotivation getRandomMotivation() {
    final random = DateTime.now().microsecond % _motivations.length;
    return _motivations[random];
  }
}
