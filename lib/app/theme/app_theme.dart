import 'package:flutter/material.dart';

abstract final class AppTheme{
  static ThemeData get dark{
    final colorScheme=ColorScheme.fromSeed(
      seedColor:const Color(0xFF5B5BD6),
      brightness:Brightness.dark,
    );

    return ThemeData(
      colorScheme:colorScheme,
      useMaterial3:true,
      scaffoldBackgroundColor:colorScheme.surface,
      visualDensity:VisualDensity.standard,
      inputDecorationTheme:const InputDecorationTheme(
        border:OutlineInputBorder(),
      ),
      cardTheme:CardThemeData(
        elevation:0,
        margin:EdgeInsets.zero,
        shape:RoundedRectangleBorder(
          borderRadius:BorderRadius.all(Radius.circular(24)),
        ),
      ),
    );
  }
}
