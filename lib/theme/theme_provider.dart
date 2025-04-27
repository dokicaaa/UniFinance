// import 'package:banking4students/theme/themes.dart';
// import 'package:flutter/material.dart';

// class ThemeProvider extends ChangeNotifier {
//   ThemeData _themeData = lightTheme;

//   ThemeData get themeData => _themeData;
//   bool get isDarkMode => _themeData == darkTheme;

//   ThemeProvider() {
//     loadTheme();
//   }

//   void setThemeData(ThemeData themeData) {
//     _themeData = themeData;
//     notifyListeners();
//     saveTheme(isDarkMode);
//   }

//   void toggleTheme() {
//     if (_themeData == lightTheme) {
//       setThemeData(darkTheme);
//     } else {
//       setThemeData(lightTheme);
//     }
//   }

//   void saveTheme(bool isDark) async {
//     // SharedPreferences prefs = await SharedPreferences.getInstance();
//     // await prefs.setBool('isDarkMode', isDark);
//   }

//   Future<void> loadTheme() async {
//     // SharedPreferences prefs = await SharedPreferences.getInstance();
//     // bool isDark = prefs.getBool('isDarkMode') ?? false;
//     // _themeData = isDark ? darkMode : lightMode;
//     // notifyListeners();
//   }
// }
