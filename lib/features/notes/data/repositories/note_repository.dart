import 'package:isar/isar.dart';

import '../models/note.dart';

class NoteRepository {
  const NoteRepository(this._isar);

  final Isar _isar;

  Future<List<Note>> getAll() {
    return _isar.notes.where().sortByUpdatedAtDesc().findAll();
  }

  Future<Note?> getBySyncId(String syncId) {
    return _isar.notes.where().syncIdEqualTo(syncId).findFirst();
  }

  Stream<List<Note>> watchAll() {
    return _isar.notes.where().sortByUpdatedAtDesc().watch(
      fireImmediately: true,
    );
  }

  Future<Id> save(Note note) {
    note.updatedAt = DateTime.now();
    return _isar.writeTxn(() => _isar.notes.put(note));
  }

  Future<void> delete(Id id) {
    return _isar.writeTxn(() => _isar.notes.delete(id));
  }
}
