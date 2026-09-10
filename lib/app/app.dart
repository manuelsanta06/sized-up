import 'package:flutter/material.dart';

import '../core/database/database_service.dart';
import '../navigation/app_shell.dart';
import 'theme/app_theme.dart';

class ScrApp extends StatelessWidget {
  const ScrApp({required this.database, super.key});

  final DatabaseService database;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: AppShell(database: database),
    );
  }
}
