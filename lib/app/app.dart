import 'package:flutter/material.dart';

import '../navigation/app_shell.dart';
import 'theme/app_theme.dart';

class ScrApp extends StatelessWidget{
  const ScrApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title:'SCR',
      debugShowCheckedModeBanner:false,
      theme:AppTheme.dark,
      darkTheme:AppTheme.dark,
      themeMode:ThemeMode.dark,
      home:const AppShell(),
    );
  }
}
