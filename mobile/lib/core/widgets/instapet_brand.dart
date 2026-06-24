import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../constants/app_constants.dart';

class InstaPetBrand extends StatelessWidget {
  const InstaPetBrand({super.key, this.fontSize = 42});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppConstants.appName,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary,
        letterSpacing: -1,
      ),
    );
  }
}
