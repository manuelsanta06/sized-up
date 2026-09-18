import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/database/database_service.dart';
import 'core/providers/app_providers.dart';

Future<void> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  final database=DatabaseService();
  await database.open();
  runApp(ProviderScope(
    overrides:[databaseProvider.overrideWithValue(database)],
    child:const ScrApp(),
  ));
}
