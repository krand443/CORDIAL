import 'package:flutter/material.dart';

// カウントの値を受け取って表示する StatelessWidget
class CounterText extends StatelessWidget {
  final int counter; // 表示するカウント値

  const CounterText({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$counter', // 受け取った値をテキストとして表示
      style: Theme.of(context).textTheme.headlineMedium, // テーマに従ったスタイル
    );
  }
}
