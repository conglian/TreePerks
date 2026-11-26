import 'package:flutter/material.dart';

import '../TPBase/TPMainTabViewport.dart';
import '../TPTool/TPImg.dart';
import '../TPTool/TPResponsive.dart';
import '../TPTool/TPText.dart';
import 'TPHomePage.dart';

const _tpQuizAssets = 'assets/image/quiz';

class TPQuizBackdrop extends StatelessWidget {
  const TPQuizBackdrop({super.key});

  @override
  Widget build(BuildContext context) => const TPMainTabBackdrop(
    backgroundColor: Colors.white,
    child: TPImg(
      name: '$_tpQuizAssets/tp_quiz_background.png',
      fit: BoxFit.cover,
    ),
  );
}

class TPQuizPage extends StatelessWidget {
  const TPQuizPage({super.key, this.onCash, this.onGuideAnswer});

  final VoidCallback? onCash;
  final ValueChanged<int>? onGuideAnswer;

  @override
  Widget build(BuildContext context) {
    return TPMainTabViewport(
      scrollKey: const PageStorageKey('tp-quiz-scroll'),
      child: Column(
        children: [
          TPHomeHeader(onCash: onCash),
          const SizedBox(height: 25),
          const _TPQuizMilestones(),
          _TPQuizBoard(onGuideAnswer: onGuideAnswer),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _TPQuizMilestones extends StatelessWidget {
  const _TPQuizMilestones();

  static const _lefts = [52.0, 164.0, 281.0];
  static const _labels = ['05', '10', '20'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: 375,
      child: Stack(
        children: [
          Positioned(
            left: 15,
            right: 15,
            top: 15,
            height: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF7698B9),
                borderRadius: BorderRadius.circular(44),
                border: Border.all(color: const Color(0xFFDBEBF9), width: 2),
              ),
            ),
          ),
          const Positioned(
            left: 16,
            width: 124.6,
            top: 16,
            height: 14,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(26)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFFFF7B00), Color(0xFFFFE500)],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 18,
            width: 121,
            top: 17,
            height: 11,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(47)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0x00FFFAD5)],
                  stops: [0, 0.41],
                ),
              ),
            ),
          ),
          for (var index = 0; index < _labels.length; index++)
            Positioned(
              left: _lefts[index],
              top: 0,
              width: 43.125,
              height: 46,
              child: TPImg(
                name: index == 0
                    ? '$_tpQuizAssets/tp_quiz_milestone_done.png'
                    : '$_tpQuizAssets/tp_quiz_milestone.png',
              ),
            ),
          const Positioned(
            left: 60.63,
            top: 13.18,
            width: 27.07,
            height: 21.38,
            child: TPImg(name: '$_tpQuizAssets/tp_quiz_milestone_check.png'),
          ),
          for (var index = 0; index < _labels.length; index++)
            Positioned(
              left: _lefts[index],
              top: index == 0 ? 31 : 30,
              width: 43.125,
              height: 18,
              child: TPText(
                text: _labels[index],
                size: 14,
                color: const Color(0xFF201C1C),
                weight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _TPQuizBoard extends StatefulWidget {
  const _TPQuizBoard({this.onGuideAnswer});

  final ValueChanged<int>? onGuideAnswer;

  @override
  State<_TPQuizBoard> createState() => _TPQuizBoardState();
}

class _TPQuizBoardState extends State<_TPQuizBoard> {
  int? _answer;

  void _choose(int answer) {
    setState(() => _answer = answer);
    widget.onGuideAnswer?.call(answer);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 375,
      height: 462,
      child: Stack(
        children: [
          const Positioned(
            left: 8,
            top: 0,
            width: 360,
            height: 462,
            child: TPImg(name: '$_tpQuizAssets/tp_quiz_board.png'),
          ),
          const Positioned(
            left: 113,
            right: 113,
            top: 45.5,
            height: 42,
            child: TPFitText(
              span: TextSpan(
                text: 'Qiuz',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF7E3003),
                  shadows: [
                    Shadow(
                      color: Color(0xFFFFF7CD),
                      offset: Offset(0, 1.2),
                      blurRadius: 1.2,
                    ),
                  ],
                ),
              ),
              align: TextAlign.center,
            ),
          ),
          const Positioned(
            left: 37,
            top: 115,
            width: 302,
            height: 151,
            child: TPImg(name: '$_tpQuizAssets/tp_quiz_question.png'),
          ),
          const Positioned(
            left: 56,
            right: 60,
            top: 159,
            height: 47,
            child: TPText(
              key: ValueKey('tp-quiz-question'),
              text: 'When can you withdraw\nyou cash?',
              size: 20,
              color: Colors.white,
              weight: FontWeight.w500,
              maxLines: 2,
            ),
          ),
          Positioned(
            left: 41,
            top: 278.5,
            width: 289,
            child: _TPQuizAnswer(
              key: const ValueKey('tp-quiz-answer-a'),
              letter: 'A',
              label: 'Jupiter',
              selected: _answer == 0,
              guideCorrect: widget.onGuideAnswer == null ? null : true,
              onPressed: () => _choose(0),
            ),
          ),
          Positioned(
            left: 41,
            top: 338.5,
            width: 289,
            child: _TPQuizAnswer(
              key: const ValueKey('tp-quiz-answer-b'),
              letter: 'B',
              label: 'Mars',
              selected: _answer == 1,
              guideCorrect: widget.onGuideAnswer == null ? null : false,
              onPressed: () => _choose(1),
            ),
          ),
          const Positioned(
            left: -128,
            top: 63,
            width: 311,
            height: 23,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xBFF9FFA3),
                borderRadius: BorderRadius.all(Radius.circular(34)),
              ),
            ),
          ),
          const Positioned(
            left: -116,
            top: 63,
            width: 254.82,
            height: 23,
            child: ExcludeSemantics(
              child: TPFitText(
                align: TextAlign.center,
                span: TextSpan(
                  style: TextStyle(fontSize: 12, color: Color(0xFF001500)),
                  children: [
                    TextSpan(
                      text: 'Player_aK9x2M',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextSpan(text: '  got 10 right and earned '),
                    TextSpan(
                      text: '\$10!',
                      style: TextStyle(
                        color: Color(0xFF007E0B),
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TPQuizAnswer extends StatelessWidget {
  const _TPQuizAnswer({
    super.key,
    required this.letter,
    required this.label,
    required this.selected,
    this.guideCorrect,
    required this.onPressed,
  });

  final String letter;
  final String label;
  final bool selected;
  final bool? guideCorrect;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(12));
    final highlight = guideCorrect ?? selected;
    final letterColor = highlight
        ? const Color(0xFF109618)
        : const Color(0xFF626672);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox(
            height: 57,
            child: Center(
              child: AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 150),
                height: 50,
                decoration: BoxDecoration(
                  color: highlight
                      ? const Color(0xFFE6FCE0)
                      : guideCorrect == false
                      ? selected
                            ? const Color(0xFFFFD7CF)
                            : const Color(0xFFFFEEE8)
                      : const Color(0xFFF5F7F9),
                  borderRadius: radius,
                  border: Border.all(
                    color: highlight
                        ? const Color(0xFF31ED28)
                        : guideCorrect == false
                        ? const Color(0xFFFF9B8E)
                        : Colors.white,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 7,
                      top: 0,
                      bottom: 0,
                      width: 34,
                      child: TPText(
                        text: letter,
                        size: 20,
                        color: letterColor,
                        weight: FontWeight.bold,
                      ),
                    ),
                    Positioned(
                      left: 44,
                      top: 9,
                      width: 1.5,
                      height: 28,
                      child: ColoredBox(
                        color: highlight
                            ? const Color(0xFF7AB87D)
                            : const Color(0xFFB6B9BC),
                      ),
                    ),
                    Positioned.fill(
                      left: 48,
                      right: 48,
                      child: TPText(
                        text: label,
                        size: 20,
                        color: const Color(0xFF05081D),
                        weight: FontWeight.w500,
                      ),
                    ),
                    if (guideCorrect == true)
                      const Positioned(
                        right: 10,
                        top: 0,
                        bottom: 0,
                        child: Icon(
                          Icons.check_circle,
                          color: Color(0xFF5CC823),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
