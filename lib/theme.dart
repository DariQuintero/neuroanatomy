import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF6750A4);
const _secondaryColor = Color(0xFFFFF8F0);
const _tertiaryColor = Color(0xFFb58392);

ThemeData mainTheme() {
  final baseTheme = ThemeData.light(useMaterial3: true);
  final mainThemeTextTheme = baseTheme.textTheme;

  return baseTheme.copyWith(
    textTheme: mainThemeTextTheme,
    colorScheme: baseTheme.colorScheme.copyWith(
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
    ),
  );
}

final roundedTextInputDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(64.0),
  ),
  filled: true,
  hintStyle: TextStyle(color: Colors.grey[800]),
  fillColor: Colors.white70,
  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
);
