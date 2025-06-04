import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

TextSpan makeLinkText(String text,BuildContext context,{double? fontSize}) {
  final RegExp urlRegex = RegExp(r'(https?:// \S+)');
  final List<TextSpan> spans = [];

  text.splitMapJoin(
    urlRegex,
    onMatch: (Match match) {
      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                throw 'Could not launch $url';
              }
            },
        ),
      );
      return '';
    },
    onNonMatch: (String nonMatch) {
      spans.add(TextSpan(text: nonMatch));
      return '';
    },
  );

  // 親ウィジェットからテーマを取得
  return TextSpan(
    style: TextStyle(fontSize: fontSize ?? 14, color:Theme.of(context).colorScheme.onSurface), // ベーススタイル
    children: spans,
  );
}
