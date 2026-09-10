import 'package:isar/isar.dart';

import '../models/calendar_event.dart';

class CalendarEventRepository {
  const CalendarEventRepository(this._isar);

  final Isar _isar;

  Future<List<CalendarEvent>> getAll() {
    return _isar.calendarEvents.where().sortByStartsAt().findAll();
  }

  Future<CalendarEvent?> getBySyncId(String syncId) {
    return _isar.calendarEvents.where().syncIdEqualTo(syncId).findFirst();
  }

  Stream<List<CalendarEvent>> watchAll() {
    return _isar.calendarEvents.where().sortByStartsAt().watch(
      fireImmediately: true,
    );
  }

  Future<Id> save(CalendarEvent event) {
    event.updatedAt = DateTime.now();
    return _isar.writeTxn(() => _isar.calendarEvents.put(event));
  }

  Future<void> delete(Id id) {
    return _isar.writeTxn(() => _isar.calendarEvents.delete(id));
  }
}
