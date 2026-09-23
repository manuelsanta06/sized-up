import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/note_providers.dart';
import '../data/models/note.dart';
import 'note_editor_page.dart';
import 'note_palette.dart';
import '../../../navigation/app_section.dart';
import '../../../navigation/search_query_provider.dart';

class NotesPage extends ConsumerWidget{
  const NotesPage({super.key});
  @override
  Widget build(BuildContext context,WidgetRef ref){
    final notes=ref.watch(notesProvider);
    final query=ref.watch(searchQueryProvider(AppSection.notes));
    return notes.when(
      loading:()=>const Center(child:CircularProgressIndicator()),
      error:(error,stackTrace)=>_NotesError(message:'Notes could not be loaded.',onRetry:()=>ref.invalidate(notesProvider)),
      data:(items)=>_NotesContent(notes:items,query:query),
    );
  }
}

class _NotesContent extends StatelessWidget{
  const _NotesContent({required this.notes,required this.query});
  final List<Note> notes;
  final String query;
  @override
  Widget build(BuildContext context){
    final displayedNotes=_notesForQuery(notes,query);
    if(displayedNotes.isEmpty)return _EmptyNotes(onCreateNote:()=>_openEditor(context));
    return ListView.separated(
      padding:const EdgeInsets.fromLTRB(20,20,20,140),
      itemCount:displayedNotes.length,
      separatorBuilder:(_,index)=>const SizedBox(height:12),
      itemBuilder:(context,index){
        final note=displayedNotes[index];
        return _NoteCard(note:note,onTap:()=>_openEditor(context,note:note));
      },
    );
  }
  void _openEditor(BuildContext context,{Note? note}){
    Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>NoteEditorPage(note:note)));
  }
  List<Note> _notesForQuery(List<Note> notes,String query)=>notes;
}

class _EmptyNotes extends StatelessWidget{
  const _EmptyNotes({required this.onCreateNote});
  final VoidCallback onCreateNote;
  @override
  Widget build(BuildContext context){
    final colorScheme=Theme.of(context).colorScheme;
    return Center(
      child:Padding(
        padding:const EdgeInsets.all(32),
        child:Column(
          mainAxisSize:MainAxisSize.min,
          children:[
            Icon(Icons.sticky_note_2_outlined,size:48,color:colorScheme.primary),
            const SizedBox(height:16),
            Text('No notes yet',style:Theme.of(context).textTheme.titleLarge),
            const SizedBox(height:8),
            Text('Create your first note to start collecting ideas.',textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodyMedium?.copyWith(color:colorScheme.onSurfaceVariant)),
            const SizedBox(height:20),
            FilledButton.icon(onPressed:onCreateNote,icon:const Icon(Icons.note_add_outlined),label:const Text('Create note')),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget{
  const _NoteCard({required this.note,required this.onTap});
  final Note note;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context){
    final colorScheme=Theme.of(context).colorScheme;
    final accentColor=noteColorFromValue(note.colorValue);
    return Card(
      color:Color.alphaBlend(accentColor.withValues(alpha:.18),colorScheme.surfaceContainerHigh),
      clipBehavior:Clip.hardEdge,
      child:ListTile(
        onTap:onTap,
        contentPadding:const EdgeInsets.symmetric(horizontal:18,vertical:8),
        leading:Container(
          width:12,
          height:48,
          decoration:BoxDecoration(
            color:accentColor,
            borderRadius:BorderRadius.circular(8)
          )
        ),
        title:Text(note.title),
        subtitle:Padding(
          padding:const EdgeInsets.only(top:4),
          child:Text(note.content.isEmpty?'No content':note.content,
          maxLines:2,
          overflow:TextOverflow.ellipsis)
        ),
        trailing:const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _NotesError extends StatelessWidget{
  const _NotesError({required this.message,required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context)=>Center(child:FilledButton.tonalIcon(
    onPressed:onRetry,
    icon:const Icon(Icons.refresh),
    label:Text(message)
  ));
}
