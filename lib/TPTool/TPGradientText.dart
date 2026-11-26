import 'TPFonts.dart';
import 'TPResponsive.dart';
import 'package:flutter/material.dart';

class TPGradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Gradient gradient;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextOverflow? overflow;
  final bool softWrap;
  final int? maxLines;
  final double? textScaleFactor;

  const TPGradientText(
    this.text, {
    super.key,
    required this.fontSize,
    required this.gradient,
    this.textAlign,
    this.textDirection,
    this.overflow,
    this.softWrap = true,
    this.maxLines,
    this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: TPFitText(
        span: TextSpan(
          text: text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: fontSize * (textScaleFactor ?? 1),
            fontFamily: TPFonts.family,
            color: Colors.white,
          ),
        ),
        align: textAlign ?? TextAlign.start,
        maxLines: maxLines,
      ),
    );
  }
}

class TPGradientStrokeText extends StatelessWidget {
  final String text;
  final List<Color> gradientColors;
  final Color strokeColor;
  final double strokeWidth;
  final int fontSize;
  final double width;
  final double height;

  const TPGradientStrokeText({
    super.key,
    required this.text,
    required this.gradientColors,
    required this.width,
    required this.height,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.bold,
      fontFamily: TPFonts.family,
      height: 1.15,
    );
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TPFitText(
            span: TextSpan(
              text: text,
              style: style.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..color = strokeColor,
              ),
            ),
            align: TextAlign.center,
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) =>
                LinearGradient(colors: gradientColors).createShader(bounds),
            child: TPFitText(
              span: TextSpan(
                text: text,
                style: style.copyWith(color: Colors.white),
              ),
              align: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
