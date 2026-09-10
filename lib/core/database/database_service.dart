import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/calendar/data/models/calendar_event.dart';
import '../../features/notes/data/models/note.dart';
import '../../features/people/data/models/person.dart';

class DatabaseService {
  Isar? _isar;
  Future<Isar>? _opening;

  Future<Isar> open() {
    final current = _isar;
    if (current != null && current.isOpen) return Future.value(current);
    return _opening ??= _open();
  }

  Future<Isar> _open() async {
    try {
      final directory = await getApplicationSupportDirectory();
      final isar = await Isar.open(
        [NoteSchema, PersonSchema, CalendarEventSchema],
        directory: directory.path,
        name: 'scr',
      );
      _isar = isar;
      return isar;
    } finally {
      _opening = null;
    }
  }

  Isar get instance {
    final isar = _isar;
    if (isar == null || !isar.isOpen) {
      throw StateError('DatabaseService.open() must be called first.');
    }
    return isar;
  }

  Future<void> close() async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      await isar.close();
    }
    _isar = null;
  }
}
