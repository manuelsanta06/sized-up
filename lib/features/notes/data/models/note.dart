import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'note.g.dart';

@collection
class Note{
  static const defaultColorValue=0xFF65558F;
  Id id=Isar.autoIncrement;
  @Index(unique: true)
  String syncId = const Uuid().v4();
  @Index()
  String title = '';
  String content = '';
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  bool archived = false;
  int colorValue = defaultColorValue;
}
