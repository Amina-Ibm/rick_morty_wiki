import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const String _themeBox = 'themeBox';
const String _isDarkKey = 'isDarkKey';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = Hive.box(_themeBox);
    final isDark = box.get(_isDarkKey, defaultValue: true);
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final isCurrentlyDark = state == ThemeMode.dark;
    final newMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    
    state = newMode;
    
    final box = Hive.box(_themeBox);
    box.put(_isDarkKey, !isCurrentlyDark);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
