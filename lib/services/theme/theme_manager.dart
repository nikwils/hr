import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeManager {
  static const mainColor = Color.fromRGBO(70, 218, 218, 1.0);
  static const iconDefaultColor = Colors.grey;
  static const drawerColor = Color.fromRGBO(41, 99, 113, 1);
  static const calendarColor = mainColor;

  final _themeDataAndroid = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: mainColor,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: mainColor,
    ),
    iconTheme: IconThemeData(
      color: Colors.grey[400],
    ),
  );

  final _themeDataIOS = const CupertinoThemeData(
    primaryColor: Colors.white,
    primaryContrastingColor: mainColor,
    brightness: Brightness.light,
    textTheme: CupertinoTextThemeData(
      navActionTextStyle: TextStyle(color: Colors.white),
      navTitleTextStyle: TextStyle(
        fontSize: 19,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  ThemeData get getThemeDataAndroid => _themeDataAndroid;
  CupertinoThemeData get getThemeDataIOS => _themeDataIOS;
}
