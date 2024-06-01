// Text Widget with custom styling

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:password_manager/utils/colors.dart';

class MyText extends StatelessWidget {
  const MyText({
    super.key,
    required this.text,
    required this.fontSize,
    this.color = white,
    this.fontWeight = FontWeight.w400,
    this.textAlign = TextAlign.left,
  });

  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
