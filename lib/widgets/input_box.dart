// Input Box with custom styling 

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:password_manager/utils/colors.dart';

class InputBox extends StatelessWidget {
  InputBox({
    super.key,
    this.text = "",
    this.enabled,
    this.initialValue = "",
    this.enableSuggestions = false,
    this.textAlign = TextAlign.left,
    this.keyboardType = TextInputType.text,
    this.autocorrect = false,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLength = null,
    this.maxLines = 1,
    this.counterText = null,
    this.textInputAction,
    required this.validator,
    required this.onSaved,
    this.onChanged,
  });

  // Custom settings to set to TextFormField making it more generic
  final String text;
  final TextAlign textAlign;
  final bool? enabled;
  final String initialValue;
  final bool enableSuggestions;
  final TextInputType keyboardType;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  Widget? suffixIcon;
  Widget? prefixIcon;
  final maxLength;
  final maxLines;
  final counterText;
  final TextInputAction? textInputAction;
  final String? Function(String?) validator;
  final void Function(String?) onSaved;
  void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      enableSuggestions: enableSuggestions,
      textAlign: textAlign,
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      maxLength: maxLength,
      maxLines: maxLines,
      textInputAction: textInputAction,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
      decoration: InputDecoration(
        counterText: counterText,
        hintText: text,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: primary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 204, 207, 212),
            width: 1.5,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
    );
  }
}
