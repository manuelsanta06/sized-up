import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/database/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = DatabaseService();
  await database.open();
  runApp(ScrApp(database: database));
}
