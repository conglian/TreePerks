import 'TPPaymentConfig.dart';
import 'TPAppKeys.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treeperks/TPTool/TPExtensionHelp.dart';
import 'package:treeperks/TPTool/TPImg.dart';
import 'package:treeperks/TPTool/TPText.dart';
// TODO: 配套源码尚未接入。
// import '../TPBase/TPTbaBar.dart';
import 'TPTBAEventTool.dart';

class TPInAppNotification {
  static final TPInAppNotification _instance = TPInAppNotification._internal();
  factory TPInAppNotification() => _instance;
  TPInAppNotification._internal();

  OverlayEntry? _overlayEntry;
  Timer? _timer;
  bool _isShowing = false;
  final Random _random = Random();

  // 可随机金额列表
  final List<int> _amounts = [100, 120, 150, 200];

  final List<String> _names = [
    'Mary',
    'James',
    'Linda',
    'Robert',
    'Sarah',
    'Michael',
  ];

  int _currentIndex = 0;

  /// 初始化计时器
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;

    if (isFirstLaunch) {
      prefs.setBool('first_launch', false);
      _startTimer(_random.nextInt(2) + 1); // 测试用 1~2 分钟
    } else {
      _startTimer(_random.nextInt(6) + 5); // 5~10 分钟
    }
  }

  void _startTimer(int minutes) {
    _timer?.cancel();
    _timer = Timer(Duration(minutes: minutes), () {
      final amount = _amounts[_random.nextInt(_amounts.length)];
      final content =
          '${_names[_currentIndex]} received ${TPPaymentConfig.money(amount)} via ${TPPaymentConfig.payment(0)} successfully';
      _showNotification('Withdrawal Sent', content);
      _currentIndex = (_currentIndex + 1) % _names.length;

      // 下一条 5~10 分钟
      _startTimer(_random.nextInt(6) + 5);
    });
  }

  void dispose() {
    _timer?.cancel();
    _overlayEntry?.remove();
  }

  void _showNotification(String title, String content) {
    tp_event_fire('push_appin_p', {});

    if (_isShowing) return;
    _isShowing = true;
    Random random = Random();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _TPNotificationWidget(
          title: title,
          content: content,
          row: random.nextInt(56),
          onComplete: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
            _isShowing = false;
          },
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = tpNavigatorKey.currentState?.overlay;
      if (overlay != null) {
        overlay.insert(_overlayEntry!);
      } else {
        _isShowing = false;
      }
    });
  }
}

// --- Notification Widget ---

class _TPNotificationWidget extends StatefulWidget {
  final String title;
  final String content;
  final int row;
  final VoidCallback onComplete;
  const _TPNotificationWidget({
    required this.title,
    required this.content,
    required this.onComplete,
    required this.row,
  });

  @override
  State<_TPNotificationWidget> createState() => _TPNotificationWidgetState();
}

class _TPNotificationWidgetState extends State<_TPNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<double>(
      begin: -104,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _controller.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 8,
      left: 7,
      right: 7,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _animation.value),
            child: child,
          ),
          child: TPInAppNotificationCard(
            title: widget.title,
            content: widget.content,
            row: widget.row,
          ),
        ),
      ),
    );
  }
}

class TPInAppNotificationCard extends StatelessWidget {
  final String title;
  final String content;
  final int row;

  const TPInAppNotificationCard({
    super.key,
    required this.title,
    required this.content,
    required this.row,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const TPImg(name: 'tp_inapp_notice_bg', width: 361, height: 76),
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 7),
            child: Row(
              children: [
                TPImg(name: 'tp_user_s_$row', width: 49, height: 49),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 23,
                        child: TPText(
                          text: title,
                          size: 18,
                          color: Colors.black,
                          weight: FontWeight.w900,
                          align: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 34,
                        child: TPText(
                          text: content,
                          size: 13,
                          color: '#152456'.color(),
                          weight: FontWeight.w600,
                          maxLines: 2,
                          align: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const SizedBox(
                  width: 68,
                  child: Icon(
                    Icons.payments_rounded,
                    size: 50,
                    color: Color(0xFF6098B7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
