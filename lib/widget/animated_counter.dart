import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final int value;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final bool formatWithComma;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.color = Colors.black,
    this.fontSize = 30,
    this.fontWeight = FontWeight.w800,
    this.formatWithComma = false,
    this.duration = const Duration(milliseconds: 1500),
  });

  String _formatNumber(int number) {
    if (!formatWithComma) return number.toString();
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, val, child) {
        return Text(
          _formatNumber(val),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            letterSpacing: 0.5,
          ),
        );
      },
    );
  }
}