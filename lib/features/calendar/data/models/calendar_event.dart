import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'calendar_event.g.dart';

@collection
class CalendarEvent {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String syncId = const Uuid().v4();

  String title = '';
  String? description;

  @Index()
  DateTime startsAt = DateTime.now();

  DateTime? endsAt;
  bool allDay = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
