import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

TextSpan makeLinkText(String text) {
  final RegExp urlRegex = RegExp(r'(https?://\S+)');
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

  return TextSpan(
    style: const TextStyle(fontSize: 14, color: Colors.black), // ベーススタイル
    children: spans,
  );
}
