import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../data/models/note.dart';
import '../../../core/providers/app_providers.dart';

final notesProvider = StreamProvider<List<Note>>((ref){
  return ref.watch(noteRepositoryProvider).watchAll();
});

final noteEditorControllerProvider=AsyncNotifierProvider<NoteEditorController,void>(NoteEditorController.new);

final noteSelectionProvider=NotifierProvider<NoteSelectionNotifier,Set<Id>>(NoteSelectionNotifier.new);

class NoteEditorController extends AsyncNotifier<void>{
  @override
  FutureOr<void> build(){}
  Future<bool> save(Note note)async{
    state = const AsyncLoading();
    final result = await AsyncValue.guard<void>(()async{
      await ref.read(noteRepositoryProvider).save(note);
    });
    state = result;
    return !result.hasError;
  }
}

class NoteSelectionNotifier extends Notifier<Set<Id>>{
  @override
  Set<Id> build()=>{};
  void toggle(Id id){
    final next={...state};
    if(!next.add(id))next.remove(id);
    state=next;
  }
  void clear()=>state={};
}
