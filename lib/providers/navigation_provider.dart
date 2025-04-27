import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  Widget _currentScreen = Container();

  int get selectedIndex => _selectedIndex;
  Widget get currentScreen => _currentScreen;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setScreen(Widget screen) {
    _currentScreen = screen;
    notifyListeners();
  }
}
