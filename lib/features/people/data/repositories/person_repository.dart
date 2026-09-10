import 'package:isar/isar.dart';

import '../models/person.dart';

class PersonRepository {
  const PersonRepository(this._isar);

  final Isar _isar;

  Future<List<Person>> getAll() {
    return _isar.persons.where().sortByName().findAll();
  }

  Future<Person?> getBySyncId(String syncId) {
    return _isar.persons.where().syncIdEqualTo(syncId).findFirst();
  }

  Stream<List<Person>> watchAll() {
    return _isar.persons.where().sortByName().watch(fireImmediately: true);
  }

  Future<Id> save(Person person) {
    person.updatedAt = DateTime.now();
    return _isar.writeTxn(() => _isar.persons.put(person));
  }

  Future<void> delete(Id id) {
    return _isar.writeTxn(() => _isar.persons.delete(id));
  }
}
