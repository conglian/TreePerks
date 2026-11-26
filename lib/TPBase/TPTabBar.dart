import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../TPTool/TPFonts.dart';
import '../TPTool/TPImg.dart';
import '../TPTool/TPResponsive.dart';

enum TPTab {
  tree('Tree'),
  dice('Dice'),
  quiz('Quiz'),
  cash('Cash');

  const TPTab(this.label);

  final String label;
}

typedef TPTabPageBuilder = Widget Function(ValueChanged<TPTab> selectTab);

class TPMainTabPage extends StatefulWidget {
  const TPMainTabPage({
    super.key,
    required this.homeBuilder,
    this.requestedTab,
    this.pageBuilders = const {},
    this.pageBackdrops = const {},
  });

  final TPTabPageBuilder homeBuilder;
  final TPTab? requestedTab;
  final Map<TPTab, TPTabPageBuilder> pageBuilders;
  final Map<TPTab, Widget> pageBackdrops;

  @override
  State<TPMainTabPage> createState() => _TPMainTabPageState();
}

class _TPMainTabPageState extends State<TPMainTabPage>
    with SingleTickerProviderStateMixin {
  static const _backgroundColor = Color(0xFFF4F5F9);
  static const _systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );

  late final AnimationController _selectionController;
  late final Animation<double> _selectionMotion;
  late final Set<TPTab> _visitedTabs;
  late TPTab _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.requestedTab ?? TPTab.tree;
    _visitedTabs = {_selected};
    _selectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      value: 1,
    );
    _selectionMotion = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.27), weight: 13),
      TweenSequenceItem(
        tween: Tween(
          begin: -0.27,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: -0.12,
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 29,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -0.12,
          end: 0.13,
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 17,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.13,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 17,
      ),
    ]).animate(_selectionController);
  }

  @override
  void didUpdateWidget(TPMainTabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.requestedTab case final tab?
        when tab != oldWidget.requestedTab) {
      _selected = tab;
      _visitedTabs.add(tab);
      _selectionController.value = 1;
    }
  }

  void _selectTab(TPTab tab) {
    if (_selected != tab) {
      setState(() {
        _selected = tab;
        _visitedTabs.add(tab);
      });
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _selectionController.value = 1;
    } else {
      _selectionController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final backdrop = widget.pageBackdrops[_selected];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemOverlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (backdrop != null)
            IgnorePointer(child: ExcludeSemantics(child: backdrop)),
          Scaffold(
            backgroundColor: backdrop == null
                ? _backgroundColor
                : Colors.transparent,
            body: SafeArea(
              bottom: false,
              minimum: isPortrait
                  ? const EdgeInsets.only(top: 40)
                  : EdgeInsets.zero,
              child: IndexedStack(
                index: _selected.index,
                sizing: StackFit.expand,
                children: [
                  for (final tab in TPTab.values)
                    TickerMode(
                      key: ValueKey(tab),
                      enabled: _selected == tab,
                      child: _visitedTabs.contains(tab)
                          ? KeyedSubtree(
                              key: ValueKey('tp-page-${tab.name}'),
                              child: _buildPage(tab),
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: _TPTabBar(
              selected: _selected,
              motion: _selectionMotion,
              onSelect: _selectTab,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(TPTab tab) {
    final builder = tab == TPTab.tree
        ? widget.homeBuilder
        : widget.pageBuilders[tab];
    return builder?.call(_selectTab) ?? const SizedBox.shrink();
  }
}

class _TPTabBar extends StatelessWidget {
  const _TPTabBar({
    required this.selected,
    required this.motion,
    required this.onSelect,
  });

  static const _barHeight = 53.0;
  static const _sideMargin = 8.0;
  static const _maxBarWidth = 450.0 - 2 * _sideMargin;
  static const _minTouchWidth = 48.0;
  static const _leftInset = 18.0;
  static const _rightInset = 16.0;

  final TPTab selected;
  final Animation<double> motion;
  final ValueChanged<TPTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minItemsWidth = TPTab.values.length * _minTouchWidth;
            final sideMargin = ((constraints.maxWidth - minItemsWidth) / 2)
                .clamp(0.0, _sideMargin);
            final barWidth = math.min(
              _maxBarWidth,
              constraints.maxWidth - 2 * sideMargin,
            );
            final insetScale =
                ((barWidth - minItemsWidth) / (_leftInset + _rightInset)).clamp(
                  0.0,
                  1.0,
                );

            return Align(
              alignment: Alignment.center,
              heightFactor: 1,
              child: SizedBox(
                width: barWidth,
                height: _barHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(56),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        offset: Offset(0, -1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: _leftInset * insetScale,
                        right: _rightInset * insetScale,
                      ),
                      child: Row(
                        children: [
                          for (final tab in TPTab.values)
                            Expanded(
                              child: _TPTabButton(
                                key: ValueKey('tp-tab-${tab.name}'),
                                tab: tab,
                                selected: tab == selected,
                                motion: motion,
                                onTap: () => onSelect(tab),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TPTabButton extends StatelessWidget {
  const _TPTabButton({
    super.key,
    required this.tab,
    required this.selected,
    required this.motion,
    required this.onTap,
  });

  static const _iconWidth = 28.61;
  static const _iconHeight = 27.38;
  static const _assetPrefix = 'assets/image/tabs/tp_tab_';
  static const _activeColor = Color(0xFF0FA669);
  static const _inactiveColor = Color(0xFFB7B7B7);

  final TPTab tab;
  final bool selected;
  final Animation<double> motion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = _buildIcon();
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        overlayColor: const WidgetStatePropertyAll(Color(0x120FA669)),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 6,
              child: Center(
                child: ExcludeSemantics(
                  child: !selected || MediaQuery.disableAnimationsOf(context)
                      ? icon
                      : AnimatedBuilder(
                          animation: motion,
                          child: icon,
                          builder: (context, child) {
                            final bounce = motion.value;
                            return Transform.translate(
                              offset: Offset(0, -7 * bounce),
                              child: Transform.rotate(
                                angle: -0.18 * bounce,
                                child: Transform.scale(
                                  scale: 1 + 0.21 * bounce,
                                  child: child,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 32,
              bottom: 0,
              child: TPFitText(
                align: TextAlign.center,
                span: TextSpan(
                  text: tab.label,
                  style: TextStyle(
                    fontFamily: TPFonts.family,
                    fontSize: 14,
                    height: 1.15,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                    color: selected ? _activeColor : _inactiveColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final artwork = '$_assetPrefix${tab.name}_${selected ? 'on' : 'off'}';
    if (selected && (tab == TPTab.dice || tab == TPTab.cash)) {
      return SizedBox(
        width: _iconWidth,
        height: _iconHeight,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            const TPImg(
              name: '${_assetPrefix}selected_badge.png',
              width: _iconWidth,
              height: _iconHeight,
            ),
            if (tab == TPTab.dice)
              TPImg(name: '${artwork}_icon.png', width: 24.43, height: 23.38)
            else
              Positioned(
                left: 1,
                child: TPImg(
                  name: '${artwork}_icon.png',
                  width: _iconWidth,
                  height: _iconHeight,
                ),
              ),
          ],
        ),
      );
    }
    return TPImg(name: '$artwork.png', width: _iconWidth, height: _iconHeight);
  }
}
