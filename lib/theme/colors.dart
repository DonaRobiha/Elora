import 'package:flutter/material.dart';

const Color eloraPrimary = Color(0xFF046C69);

final ValueNotifier<ThemeMode> eloraThemeMode = ValueNotifier(ThemeMode.light);
final ValueNotifier<double> eloraTextScale = ValueNotifier(1.0);

bool get isEloraDark => eloraThemeMode.value == ThemeMode.dark;

Color get eloraDark => isEloraDark ? Colors.white : const Color(0xFF1D2423);
Color get eloraBackground =>
    isEloraDark ? const Color(0xFF0D1514) : const Color(0xFFF6F7F6);
Color get eloraCard => isEloraDark ? const Color(0xFF162220) : Colors.white;
Color get eloraInput =>
    isEloraDark ? const Color(0xFF33413F) : const Color(0xFFD9D9D9);
