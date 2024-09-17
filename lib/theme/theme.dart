import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      textTheme: TextTheme(titleMedium: TextStyle(color: Colors.black)),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.grey.shade900,
        unselectedItemColor: Colors.grey.shade600,
      ));

  static ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.black,
      textTheme: TextTheme(titleMedium: TextStyle(color: Colors.white)),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.deepPurple,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.grey.shade200,
        unselectedItemColor: Colors.grey.shade600,
      ));
}
