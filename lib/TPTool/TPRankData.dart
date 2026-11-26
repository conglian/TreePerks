import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TPUserData {
  final int id;
  final String username;
  final double totalEarning;
  final int adsWatched;

  TPUserData({
    required this.id,
    required this.username,
    required this.totalEarning,
    required this.adsWatched,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'totalEarning': totalEarning,
    'adsWatched': adsWatched,
  };

  factory TPUserData.fromJson(Map<String, dynamic> json) {
    return TPUserData(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      username: json['username'].toString(),
      totalEarning: json['totalEarning'] is double
          ? json['totalEarning']
          : double.parse(json['totalEarning'].toString()),
      adsWatched: json['adsWatched'] is int
          ? json['adsWatched']
          : int.parse(json['adsWatched'].toString()),
    );
  }
}

class TPUserDataManager {
  static const String _lastUpdateKey = 'lastUpdate';
  static const String _dataKey = 'TPUserData';
  static const String _dayKey = 'tp_rank_day';
  static Future<List<TPUserData>> _pending = Future.value(<TPUserData>[]);

  static String dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  static DateTime nextRefreshAt(DateTime now) =>
      DateTime(now.year, now.month, now.day + 1);
  static final Random _random = Random();

  /// 生成随机用户数据
  static List<TPUserData> generatePSUserData() {
    List<TPUserData> list = [];
    List<double> earnings = [];
    List<int> ads = [];

    // 生成 Total earning
    // 前三条 > 100 且 < 200
    for (int i = 0; i < 3; i++) {
      earnings.add(100 + _random.nextDouble() * 100); // 100~200
      ads.add(100 + _random.nextInt(100)); // 100~199
    }

    // 后面 53 条 < 100
    for (int i = 3; i < 56; i++) {
      earnings.add(_random.nextDouble() * 100); // 0~100
      ads.add(_random.nextInt(100)); // 0~99
    }

    // 按从大到小排序
    earnings.sort((b, a) => a.compareTo(b));
    ads.sort((b, a) => a.compareTo(b));

    List<String> regions = ['Texas', 'Brazil'];

    for (int i = 0; i < 56; i++) {
      String username =
          'User ****${1000 + _random.nextInt(9000)} (${regions[_random.nextInt(2)]})';
      list.add(
        TPUserData(
          id: i,
          username: username,
          totalEarning: double.parse(earnings[i].toStringAsFixed(2)),
          adsWatched: ads[i],
        ),
      );
    }

    return list;
  }

  /// 保存数据到本地
  static Future<void> savePSUserData(
    List<TPUserData> data, {
    DateTime? now,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = data.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_dataKey, jsonList);
    final timestamp = now ?? DateTime.now();
    await prefs.setString(_lastUpdateKey, timestamp.toIso8601String());
    await prefs.setString(_dayKey, dayKey(timestamp));
  }

  /// 加载本地数据
  static Future<List<TPUserData>> loadPSUserData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_dataKey);
    if (jsonList == null) return [];

    return jsonList.map((e) {
      Map<String, dynamic> map = jsonDecode(e);
      return TPUserData.fromJson(map);
    }).toList();
  }

  /// 按设备当地日期刷新；冷启动、回前台、零点回调共享同一份当天数据。
  /// 串行处理并发请求，避免零点或重新进入首页时生成两份排行榜。
  static Future<List<TPUserData>> getPSUserData({DateTime? now}) {
    Future<List<TPUserData>> read() => _loadDaily(now ?? DateTime.now());
    _pending = _pending.then((_) => read(), onError: (_) => read());
    return _pending;
  }

  static Future<List<TPUserData>> _loadDaily(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = DateTime.tryParse(prefs.getString(_lastUpdateKey) ?? '');
    final savedDay =
        prefs.getString(_dayKey) ??
        (lastUpdate == null ? null : dayKey(lastUpdate.toLocal()));
    if (savedDay == dayKey(now)) {
      try {
        final saved = await loadPSUserData();
        if (saved.length == 56) return saved;
      } catch (_) {
        // 损坏或不完整的缓存按当天重新生成，避免首页索引越界。
      }
    }
    final data = generatePSUserData();
    await savePSUserData(data, now: now);
    return data;
  }
}

/// 前台精确计时到下一个当地零点；后台停止计时，返回时补做日期检查。
class TPDailyRankRefresher with WidgetsBindingObserver {
  final Future<void> Function() onRefresh;
  final DateTime Function() now;
  Timer? _timer;
  String? _shownDay;
  bool _active = false;
  bool _disposed = false;
  Future<void> _pending = Future.value();

  TPDailyRankRefresher({required this.onRefresh, DateTime Function()? now})
    : now = now ?? DateTime.now;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _active = true;
    _refreshAndPlan();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _timer?.cancel();
    if (_active) _refreshAndPlan();
  }

  void _refreshAndPlan() {
    _pending = _pending
        .then((_) async {
          if (_disposed || !_active) return;
          final day = TPUserDataManager.dayKey(now());
          if (_shownDay != day) {
            await onRefresh();
            if (_disposed || !_active) return;
            _shownDay = day;
            if (TPUserDataManager.dayKey(now()) != day) {
              _refreshAndPlan();
              return;
            }
          }
          _timer?.cancel();
          final current = now();
          _timer = Timer(
            TPUserDataManager.nextRefreshAt(current).difference(current),
            _refreshAndPlan,
          );
        })
        .catchError((Object error, StackTrace stack) {
          if (!_disposed && _active) {
            _timer = Timer(const Duration(seconds: 1), _refreshAndPlan);
          }
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stack,
              library: 'PigWallet daily rankings',
            ),
          );
        });
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}
