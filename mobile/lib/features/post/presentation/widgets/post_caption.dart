import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class PostCaption extends StatelessWidget {
  const PostCaption({
    super.key,
    required this.username,
    required this.caption,
    this.fontSize = 14,
  });

  final String username;
  final String caption;
  final double fontSize;

  static const _baseStyle = TextStyle(
    color: AppColors.textPrimary,
    decoration: TextDecoration.none,
    decorationThickness: 0,
    height: 1.35,
  );

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: _baseStyle.copyWith(fontSize: fontSize),
        children: [
          TextSpan(
            text: '$username ',
            style: _baseStyle.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: caption,
            style: _baseStyle.copyWith(fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
