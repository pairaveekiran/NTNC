import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final int value;

  const AnimatedCounter({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(seconds: 2),
      builder: (context, val, child) {
        return Text(
          "$val",
          style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold),
        );
      },
    );
  }
}