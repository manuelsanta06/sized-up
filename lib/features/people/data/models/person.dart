import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'person.g.dart';

@collection
class Person {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String syncId = const Uuid().v4();

  @Index()
  String name = '';

  String? email;
  String? phone;
  String? notes;
  DateTime? birth;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
