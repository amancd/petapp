import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme = lightTheme;

  ThemeData get currentTheme => _currentTheme;

  void updateTheme(ThemeData newTheme) {
    _currentTheme = newTheme;
    notifyListeners();
  }
}


final lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

final darkTheme = ThemeData(
  primarySwatch: Colors.teal,
  backgroundColor: Colors.black,
  hintColor: Colors.white70,
  brightness: Brightness.dark,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);


ThemeData toggleTheme(ThemeData currentTheme) {
  return currentTheme.brightness == Brightness.light ? darkTheme : lightTheme;
}
