import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/calendar/data/repositories/calendar_event_repository.dart';
import '../../features/notes/data/repositories/note_repository.dart';
import '../../features/people/data/repositories/person_repository.dart';
import '../database/database_service.dart';

final databaseProvider=Provider<DatabaseService>((ref){
  throw StateError('databaseProvider must be overridden at application startup.');
});

final noteRepositoryProvider=Provider<NoteRepository>((ref){
  final database=ref.watch(databaseProvider);
  return NoteRepository(database.instance);
});

final personRepositoryProvider=Provider<PersonRepository>((ref){
  final database=ref.watch(databaseProvider);
  return PersonRepository(database.instance);
});

final calendarEventRepositoryProvider=Provider<CalendarEventRepository>((ref){
  final database=ref.watch(databaseProvider);
  return CalendarEventRepository(database.instance);
});
