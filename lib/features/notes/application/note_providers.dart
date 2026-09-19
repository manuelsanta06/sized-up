import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/note.dart';
import '../../../core/providers/app_providers.dart';

final notesProvider = StreamProvider<List<Note>>((ref){
  return ref.watch(noteRepositoryProvider).watchAll();
});

final noteEditorControllerProvider=AsyncNotifierProvider<NoteEditorController,void>(NoteEditorController.new);

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
